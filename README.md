## Intro

This repository contains personal build scripts for compiling LineageOS 23.2 kernels with ReSukiSU and SUSFS for OnePlus SM8650 devices (e.g. corvette).

## Quickstart

First, run:

```sh
./update.sh
````

This script will clone (or update) the kernel source and related components. It will also:

* Install ReSukiSU
* Apply SUSFS patches
* Modify the `defconfig`

⚠️ **Important:**
Even if errors are shown during SUSFS patching, the process may have already partially succeeded.
**Do not re-run `./update.sh` after fixing conflicts**, or your manual changes will be overwritten and the same conflicts will occur again.

Errors during this step are expected. You will need to resolve them manually. See [Troubleshooting](#troubleshooting).

After fixing any issues, run:

```sh
./clean.sh
```

This removes temporary files and failed patch artifacts.

Then build the kernel:

```sh
./build.sh
```

Once the build is complete, package it:

```sh
./pack.sh
```

The output AnyKernel3 zip will be generated in the current directory, named like:

```
Kernel_sm8650_<buildtime>.zip
```

**Do not use the symbolic link version of the output file.**

## Troubleshooting

It is common for `./update.sh` to report errors when applying SUSFS patches.

You may see files like:

```
fs/namespaces.c.rej
```

To fix this:

1. Open both:

   * `sm8650/fs/namespaces.c.rej`
   * `sm8650/fs/namespaces.c`

2. Manually apply the rejected patch:

   * Locate matching context lines (those without `+` or `-`)
   * Remove lines marked with `-`
   * Add lines marked with `+`

3. Save the file and continue

⚠️ **Do not re-run `./update.sh` after resolving `.rej` conflicts.**
Doing so will reset your fixes and reintroduce the same patch failures.

Yes, this step is manual. There is no automatic fix.
