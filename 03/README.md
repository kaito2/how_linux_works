## 3章 プロセス管理

```
$ docker run --rm -it -v `pwd`:/workspace sandbox
```

### `fork()` 関数

`fork()` の返り値で分岐する…ﾅﾙﾎﾄﾞ

```
$ cc -o fork fork.c
$ ./fork
I'm parent! my pid is 16 and the pid of my child is 17
I'm child! my pid is 17.
```

### プロセスのメモリマップを確認

コードとデータのファイル内オフセット、サイズ、開始アドレスを取得

```
$ readelf -h /bin/sleep
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x1b70
  Start of program headers:          64 (bytes into file)
  Start of section headers:          33208 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         9
  Size of section headers:           64 (bytes)
  Number of section headers:         28
  Section header string table index: 27

$ readelf -S /bin/sleep
There are 28 section headers, starting at offset 0x81b8:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000000000238  00000238
       000000000000001c  0000000000000000   A       0     0     1
  [ 2] .note.ABI-tag     NOTE             0000000000000254  00000254
       0000000000000020  0000000000000000   A       0     0     4
  [ 3] .note.gnu.build-i NOTE             0000000000000274  00000274
       0000000000000024  0000000000000000   A       0     0     4
  [ 4] .gnu.hash         GNU_HASH         0000000000000298  00000298
       000000000000006c  0000000000000000   A       5     0     8
  [ 5] .dynsym           DYNSYM           0000000000000308  00000308
       00000000000006c0  0000000000000018   A       6     1     8
  [ 6] .dynstr           STRTAB           00000000000009c8  000009c8
       000000000000034a  0000000000000000   A       0     0     1
  [ 7] .gnu.version      VERSYM           0000000000000d12  00000d12
       0000000000000090  0000000000000002   A       5     0     2
  [ 8] .gnu.version_r    VERNEED          0000000000000da8  00000da8
       0000000000000060  0000000000000000   A       6     1     8
  [ 9] .rela.dyn         RELA             0000000000000e08  00000e08
       00000000000002b8  0000000000000018   A       5     0     8
  [10] .rela.plt         RELA             00000000000010c0  000010c0
       00000000000004b0  0000000000000018  AI       5    23     8
  [11] .init             PROGBITS         0000000000001570  00001570
       0000000000000017  0000000000000000  AX       0     0     4
  [12] .plt              PROGBITS         0000000000001590  00001590
       0000000000000330  0000000000000010  AX       0     0     16
  [13] .plt.got          PROGBITS         00000000000018c0  000018c0
       0000000000000008  0000000000000008  AX       0     0     8
  [14] .text             PROGBITS         00000000000018d0  000018d0
       0000000000003989  0000000000000000  AX       0     0     16
  [15] .fini             PROGBITS         000000000000525c  0000525c
       0000000000000009  0000000000000000  AX       0     0     4
  [16] .rodata           PROGBITS         0000000000005280  00005280
       0000000000000d20  0000000000000000   A       0     0     32
  [17] .eh_frame_hdr     PROGBITS         0000000000005fa0  00005fa0
       000000000000026c  0000000000000000   A       0     0     4
  [18] .eh_frame         PROGBITS         0000000000006210  00006210
       0000000000000c20  0000000000000000   A       0     0     8
  [19] .init_array       INIT_ARRAY       0000000000207b70  00007b70
       0000000000000008  0000000000000008  WA       0     0     8
  [20] .fini_array       FINI_ARRAY       0000000000207b78  00007b78
       0000000000000008  0000000000000008  WA       0     0     8
  [21] .data.rel.ro      PROGBITS         0000000000207b80  00007b80
       00000000000000b8  0000000000000000  WA       0     0     32
  [22] .dynamic          DYNAMIC          0000000000207c38  00007c38
       00000000000001f0  0000000000000010  WA       6     0     8
  [23] .got              PROGBITS         0000000000207e28  00007e28
       00000000000001d0  0000000000000008  WA       0     0     8
  [24] .data             PROGBITS         0000000000208000  00008000
       0000000000000080  0000000000000000  WA       0     0     32
  [25] .bss              NOBITS           0000000000208080  00008080
       00000000000001c0  0000000000000000  WA       0     0     32
  [26] .gnu_debuglink    PROGBITS         0000000000000000  00008080
       0000000000000034  0000000000000000           0     0     4
  [27] .shstrtab         STRTAB           0000000000000000  000080b4
       0000000000000101  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)
```

上記から

|領域名|値|
|---|---|
|コード領域のファイル内オフセット|`0x18d0`|
|コード領域のサイズ|`0x3989`|
|コード領のメモリマップ開始アドレス|`0x18d0`|
|データ領域のサイズ|`0x80`|
|データ領域のメモリマップ開始アドレス|`0x8000`|
|エントリポイント|`0x1b70`|

```
$ /bin/sleep 10000 &
[2] 24
$ cat /proc/24/maps
55f9a549a000-55f9a54a1000 r-xp 00000000 08:01 3421334                    /bin/sleep
55f9a56a1000-55f9a56a2000 r--p 00007000 08:01 3421334                    /bin/sleep
55f9a56a2000-55f9a56a3000 rw-p 00008000 08:01 3421334                    /bin/sleep
55f9a6b03000-55f9a6b24000 rw-p 00000000 00:00 0                          [heap]
7f2a673ce000-7f2a675b5000 r-xp 00000000 08:01 3421618                    /lib/x86_64-linux-gnu/libc-2.27.so
7f2a675b5000-7f2a677b5000 ---p 001e7000 08:01 3421618                    /lib/x86_64-linux-gnu/libc-2.27.so
7f2a677b5000-7f2a677b9000 r--p 001e7000 08:01 3421618                    /lib/x86_64-linux-gnu/libc-2.27.so
7f2a677b9000-7f2a677bb000 rw-p 001eb000 08:01 3421618                    /lib/x86_64-linux-gnu/libc-2.27.so
7f2a677bb000-7f2a677bf000 rw-p 00000000 00:00 0
7f2a677bf000-7f2a677e6000 r-xp 00000000 08:01 3421600                    /lib/x86_64-linux-gnu/ld-2.27.so
7f2a679e0000-7f2a679e2000 rw-p 00000000 00:00 0
7f2a679e6000-7f2a679e7000 r--p 00027000 08:01 3421600                    /lib/x86_64-linux-gnu/ld-2.27.so
7f2a679e7000-7f2a679e8000 rw-p 00028000 08:01 3421600                    /lib/x86_64-linux-gnu/ld-2.27.so
7f2a679e8000-7f2a679e9000 rw-p 00000000 00:00 0
7ffe2049f000-7ffe204c0000 rw-p 00000000 00:00 0                          [stack]
7ffe205d0000-7ffe205d2000 r--p 00000000 00:00 0                          [vvar]
7ffe205d2000-7ffe205d4000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
```

### `execve()` 関数

```
$ cc -o fork-and-exec fork-and-exec.c
$ ./fork-and-exec
I'm parent! my pid is 32 and the pid of my child is 33.
I'm child! my pid is 33.
$ hello
```
