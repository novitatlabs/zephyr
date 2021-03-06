# SPDX-License-Identifier: Apache-2.0

set(EMU_PLATFORM qemu)

if(NOT CONFIG_REBOOT)
  set(REBOOT_FLAG -no-reboot)
endif()

if(CONFIG_X86_64)
  set(QEMU_binary_suffix x86_64)
  set(QEMU_CPU_TYPE_${ARCH} qemu64,+x2apic)
  if("${CONFIG_MP_NUM_CPUS}" STREQUAL "1")
    # icount works with 1 CPU so we can enable it here.
    # FIXME: once this works across configs, remove this line and set
    # CONFIG_QEMU_ICOUNT_SHIFT in defconfig instead.
    list(APPEND QEMU_EXTRA_FLAGS -icount shift=5,align=off,sleep=off -rtc clock=vm)
  endif()
else()
  set(QEMU_CPU_TYPE_${ARCH} qemu32,+nx,+pae)
endif()

if(CONFIG_XIP)
  # Extra 4MB to emulate flash area
  math(EXPR QEMU_MEMORY_SIZE_MB "${CONFIG_SRAM_SIZE} / 1024 + 4")
else()
  math(EXPR QEMU_MEMORY_SIZE_MB "${CONFIG_SRAM_SIZE} / 1024")
endif()

set(QEMU_FLAGS_${ARCH}
  -m ${QEMU_MEMORY_SIZE_MB}
  -cpu ${QEMU_CPU_TYPE_${ARCH}}
  -device isa-debug-exit,iobase=0xf4,iosize=0x04
  ${REBOOT_FLAG}
  -nographic
  )

if(NOT CONFIG_ACPI)
  list(APPEND QEMU_FLAGS_${ARCH} -no-acpi)
endif()

# TODO: Support debug
# board_set_debugger_ifnset(qemu)
# debugserver: QEMU_EXTRA_FLAGS += -s -S
# debugserver: qemu
