cmake_minimum_required(VERSION 3.22)
project(datum_core LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Solo para desarrollo en escritorio (la app compila el núcleo con el hook de Flutter).
set(OCCT_ROOT "" CACHE PATH "Instalación de OCCT (carpeta con lib/ e include/)")
if(NOT OCCT_ROOT)
  message(FATAL_ERROR "Define -DOCCT_ROOT=<ruta a la instalación de OCCT>")
endif()
file(GLOB OCCT_LIBS "${OCCT_ROOT}/lib/libTK*.a")

add_library(datum_core STATIC src/datum_cad.cpp)
target_include_directories(datum_core PUBLIC include ${OCCT_ROOT}/include/opencascade)
target_link_libraries(datum_core PUBLIC ${OCCT_LIBS})

add_executable(datum-cli src/datum_cli.cpp)
target_link_libraries(datum-cli PRIVATE datum_core)

add_executable(datum-step-probe src/step_probe.cpp)
target_include_directories(datum-step-probe PRIVATE ${OCCT_ROOT}/include/opencascade)
target_link_libraries(datum-step-probe PRIVATE ${OCCT_LIBS})
