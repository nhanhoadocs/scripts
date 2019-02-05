# Sript Utilities

## CMD_log (CentOS & Ubuntu)
```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/cmdlog.sh | bash
```

## Create Swap
```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/create_swap.sh | bash -s <size>
```

- Lưu ý: `<size>` chính là size swap (GB)

## Benchmark

```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/bench_vm.sh | bash
```

## Công cụ tra log đồng thời trên nhiều file

Tải file `logview.sh`

```sh
wget https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/logview.sh
```

Thực thi lệnh với các tùy chọn

- Tùy chọn chỉ xem các dòng có từ ERROR: `bash logview.sh ERROR`
- Tùy chọn xem các dòng có từ ERROR hoặc WARNING: `bash logview.sh "ERROR|Warning"`

