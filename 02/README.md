## 2章 ユーザーモードで実現する機能

```
$ docker run --rm -it -v `pwd`:/workspace sandbox
```

p.19

以下を見れば分かる通り、 `loop.c` のコードはシステムコールを呼ばないのですべてユーザーモードで動作している。

なので、 `%user` の値が大きくなる。

```
$ cc -o loop loop.c
$ ./loop &
[1] 890
$ sar -P ALL 1 1
Linux 4.9.184-linuxkit (4666df79cfec) 	04/17/20 	_x86_64_	(6 CPU)

13:51:28        CPU     %user     %nice   %system   %iowait    %steal     %idle
13:51:29        all     18.18      0.00      2.06      0.00      0.00     79.76
13:51:29          0     93.00      0.00      2.00      0.00      0.00      5.00
13:51:29          1      2.11      0.00      1.05      0.00      0.00     96.84
13:51:29          2      3.03      0.00      3.03      0.00      0.00     93.94
13:51:29          3      2.06      0.00      0.00      0.00      0.00     97.94
13:51:29          4      6.12      0.00      5.10      0.00      0.00     88.78
13:51:29          5      0.00      0.00      1.06      0.00      0.00     98.94

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all     18.18      0.00      2.06      0.00      0.00     79.76
Average:          0     93.00      0.00      2.00      0.00      0.00      5.00
Average:          1      2.11      0.00      1.05      0.00      0.00     96.84
Average:          2      3.03      0.00      3.03      0.00      0.00     93.94
Average:          3      2.06      0.00      0.00      0.00      0.00     97.94
Average:          4      6.12      0.00      5.10      0.00      0.00     88.78
Average:          5      0.00      0.00      1.06      0.00      0.00     98.94
$ kill 890
```

p.20

`ppidloop.c` のコードはシステムコールを呼ぶため、 `%system` の値が先程より大きくなっている。

```
$ cc -o ppidloop ppidloop.c
$ ./ppidloop &
[1] 904
$ sar -P ALL 1 1
Linux 4.9.184-linuxkit (4666df79cfec) 	04/17/20 	_x86_64_	(6 CPU)

13:59:10        CPU     %user     %nice   %system   %iowait    %steal     %idle
13:59:11        all     12.16      0.00      8.22      0.00      0.00     79.62
13:59:11          0      0.00      0.00      2.08      0.00      0.00     97.92
13:59:11          1      2.08      0.00      0.00      0.00      0.00     97.92
13:59:11          2      2.06      0.00      2.06      0.00      0.00     95.88
13:59:11          3      2.02      0.00      4.04      0.00      0.00     93.94
13:59:11          4     63.00      0.00     37.00      0.00      0.00      0.00
13:59:11          5      2.08      0.00      3.12      0.00      0.00     94.79

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all     12.16      0.00      8.22      0.00      0.00     79.62
Average:          0      0.00      0.00      2.08      0.00      0.00     97.92
Average:          1      2.08      0.00      0.00      0.00      0.00     97.92
Average:          2      2.06      0.00      2.06      0.00      0.00     95.88
Average:          3      2.02      0.00      4.04      0.00      0.00     93.94
Average:          4     63.00      0.00     37.00      0.00      0.00      0.00
Average:          5      2.08      0.00      3.12      0.00      0.00     94.79
$ kill 904
```

p.22

```
$ strace -T -o hello.log ./hello
hello world
$ cat hello.log
execve("./hello", ["./hello"], 0x7ffc2d235fb8 /* 8 vars */) = 0 <0.001987>
brk(NULL)                               = 0x564446818000 <0.000021>
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory) <0.000022>
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory) <0.000025>
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3 <0.000028>
fstat(3, {st_mode=S_IFREG|0644, st_size=13078, ...}) = 0 <0.000021>
mmap(NULL, 13078, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f5a016c6000 <0.000025>
close(3)                                = 0 <0.000021>
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory) <0.000020>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3 <0.000039>
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\34\2\0\0\0\0\0"..., 832) = 832 <0.000026>
fstat(3, {st_mode=S_IFREG|0755, st_size=2030544, ...}) = 0 <0.000022>
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5a016c4000 <0.000034>
mmap(NULL, 4131552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f5a010b2000 <0.000027>
mprotect(0x7f5a01299000, 2097152, PROT_NONE) = 0 <0.000025>
mmap(0x7f5a01499000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e7000) = 0x7f5a01499000 <0.000060>
mmap(0x7f5a0149f000, 15072, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f5a0149f000 <0.000034>
close(3)                                = 0 <0.000018>
arch_prctl(ARCH_SET_FS, 0x7f5a016c54c0) = 0 <0.000017>
mprotect(0x7f5a01499000, 16384, PROT_READ) = 0 <0.000025>
mprotect(0x564444e68000, 4096, PROT_READ) = 0 <0.000018>
mprotect(0x7f5a016ca000, 4096, PROT_READ) = 0 <0.000020>
munmap(0x7f5a016c6000, 13078)           = 0 <0.000024>
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0 <0.000019>
brk(NULL)                               = 0x564446818000 <0.000018>
brk(0x564446839000)                     = 0x564446839000 <0.000023>
write(1, "hello world\n", 12)           = 12 <0.000046>
exit_group(0)                           = ?
+++ exited with 0 +++
```

