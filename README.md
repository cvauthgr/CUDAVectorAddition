# CUDA Vector Addition

![CUDA](https://img.shields.io/badge/CUDA-13.x-76B900?logo=nvidia&logoColor=white)
![C++](https://img.shields.io/badge/C%2B%2B-23-00599C?logo=cplusplus&logoColor=white)
![Build](https://img.shields.io/badge/build-make-blue)
![Platform](https://img.shields.io/badge/platform-Windows%20(MSVC)-0078D6?logo=windows&logoColor=white)

A rewrite of the classic "first CUDA program" from the Nvidia CUDA tutorials, reworked to follow proper modern C++23 practices.

## Requirements

| Requirement | Notes |
|---|---|
| NVIDIA GPU | Must support CUDA 13.x (tested on an RTX 3050) |
| CUDA Toolkit | Version 13.x |
| Make | Used as the build system |
| MSVC | Required if building on Windows |

> **Note:** You'll need to determine your GPU's compute capability and update the `sm_XX` flag accordingly before building.

## Project Structure

Place all provided files in a single directory (unpacked, not nested in subfolders):

```
your-project-dir/
├── file.cu
├── makefile
└── header.h
```

## Build & Run

1. `cd` into the project directory.
2. Build with:
   ```
   make
   ```
3. Run the resulting executable.

## Usage

The executable accepts the vector length as its first command-line argument (max value: 2³² − 1):

```
./executable vectorLength
```
