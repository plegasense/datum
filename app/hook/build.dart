import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:flutter_gpu_shaders/build.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'draco_sources.dart';
import 'laszip_sources.dart';

/// Hook de compilación de Dovexa:
///  1. compila los shaders de Flutter GPU;
///  2. compila el núcleo C++ (core/) enlazado con Open CASCADE para la plataforma de destino.
void main(List<String> args) async {
  await build(args, (input, output) async {
    await buildShaderBundleJson(
      buildInput: input,
      buildOutput: output,
      manifestFileName: 'dovexa.shaderbundle.json',
    );

    if (!input.config.buildCodeAssets) return;
    final code = input.config.code;
    final root = input.packageRoot.resolve('../').toFilePath();
    final stub =
        code.targetOS == OS.iOS &&
        code.iOS.targetSdk == IOSSdk.iPhoneSimulator &&
        code.targetArchitecture == Architecture.x64;
    if (stub) {
      // El simulador de iOS en Intel no lleva Open CASCADE: API vacía para que enlace.
      await CBuilder.library(
        name: 'dovexa_core',
        assetName: 'src/dovexa_ffi.dart',
        sources: ['../core/src/dovexa_stub.cpp'],
        includes: ['../core/include'],
        language: Language.cpp,
        std: 'c++17',
      ).run(input: input, output: output, logger: Logger('dovexa_core'));
      return;
    }
    final occt = _occtInstall(root, code);
    if (!Directory(occt).existsSync()) {
      throw Exception(
        'Falta Open CASCADE para ${code.targetOS}/${code.targetArchitecture}: $occt\n'
        'Compílalo con los scripts de tools/build_occt_*.sh',
      );
    }
    final libNames =
        Directory('$occt/lib')
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((n) => n.startsWith('libTK') && n.endsWith('.a'))
            .map((n) => n.substring(3, n.length - 2))
            .toList()
          ..sort();

    final builder = CBuilder.library(
      name: 'dovexa_core',
      assetName: 'src/dovexa_ffi.dart',
      sources: [
        '../core/src/dovexa_cad.cpp',
        '../core/src/dovexa_draco.cpp',
        '../core/src/dovexa_laz.cpp',
        for (final f in laszipSources) '../third_party/laszip/src/$f',
        for (final f in dracoSources) '../third_party/draco/src/$f',
      ],
      includes: [
        '../core/include',
        '../core/include/draco_gen',
        '../third_party/draco/src',
        '../third_party/laszip/src',
        '../third_party/laszip/dll',
        '../third_party/laszip/include/laszip',
        '$occt/include/opencascade',
      ],
      language: Language.cpp,
      std: 'c++17',
      defines: {'UNORDERED': null, 'HAVE_UNORDERED_MAP': '1', 'LASZIPDLL_EXPORTS': null},
      flags: ['-Wno-deprecated-declarations', '-Wno-#pragma-messages', '-w'],
      libraries: [...libNames, if (code.targetOS == OS.android) ...['m', 'log']],
      libraryDirectories: ['$occt/lib'],
      cppLinkStdLib: code.targetOS == OS.android ? 'c++_static' : null,
      dartBuildFiles: ['hook/build.dart'],
    );
    await builder.run(
      input: input,
      output: output,
      logger: Logger('dovexa_core')
        ..onRecord.listen((r) => stderr.writeln(r.message)),
    );
    output.dependencies.addAll([
      input.packageRoot.resolve('../core/src/dovexa_cad.cpp'),
      input.packageRoot.resolve('../core/src/dovexa_draco.cpp'),
      input.packageRoot.resolve('../core/src/dovexa_laz.cpp'),
      input.packageRoot.resolve('../core/include/dovexa.h'),
    ]);
  });
}

String _occtInstall(String root, CodeConfig code) {
  final base = '${root}third_party/_install';
  switch (code.targetOS) {
    case OS.macOS:
      return '$base/occt-macos';
    case OS.iOS:
      final sdk = code.iOS.targetSdk == IOSSdk.iPhoneSimulator
          ? 'simulator'
          : 'device';
      return '$base/occt-ios-$sdk';
    case OS.android:
      final abi = switch (code.targetArchitecture) {
        Architecture.arm64 => 'arm64-v8a',
        Architecture.x64 => 'x86_64',
        Architecture.arm => 'armeabi-v7a',
        _ => code.targetArchitecture.toString(),
      };
      return '$base/occt-android-$abi';
    default:
      throw UnsupportedError('Plataforma no soportada: ${code.targetOS}');
  }
}
