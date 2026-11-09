cmake_minimum_required(VERSION 3.22)
project(dovexa_core LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Solo para desarrollo en escritorio (la app compila el núcleo con el hook de Flutter).
set(OCCT_ROOT "" CACHE PATH "Instalación de OCCT (carpeta con lib/ e include/)")
if(NOT OCCT_ROOT)
  message(FATAL_ERROR "Define -DOCCT_ROOT=<ruta a la instalación de OCCT>")
endif()
file(GLOB OCCT_LIBS "${OCCT_ROOT}/lib/libTK*.a")

add_library(dovexa_core STATIC src/dovexa_cad.cpp)
target_include_directories(dovexa_core PUBLIC include ${OCCT_ROOT}/include/opencascade)
target_link_libraries(dovexa_core PUBLIC ${OCCT_LIBS})

add_executable(dovexa-cli src/dovexa_cli.cpp)
target_link_libraries(dovexa-cli PRIVATE dovexa_core)

add_executable(dovexa-step-probe src/step_probe.cpp)
target_include_directories(dovexa-step-probe PRIVATE ${OCCT_ROOT}/include/opencascade)
target_link_libraries(dovexa-step-probe PRIVATE ${OCCT_LIBS})
