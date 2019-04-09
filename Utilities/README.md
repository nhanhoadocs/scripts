# Sript Utilities

Các script được sử dụng bởi team RD - Nhân Hòa

## 1. CMD_log (CentOS & Ubuntu)
```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/cmdlog.sh | bash
```

## 2. Script tạo swap đối với các máy chủ linux
```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/create_swap.sh | bash -s <size>
```

- Lưu ý: `<size>` chính là size swap (GB)

## 3. Script dùng để benchmark IOPS và latencty của disk.

```sh 
curl -Lso- https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/bench_vm.sh | bash
```

## 4. Công cụ tra log đồng thời trên nhiều file

Tải file `logview.sh`

```sh
wget https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/logview.sh
```

Thực thi lệnh với các tùy chọn

- Tùy chọn chỉ xem các dòng có từ ERROR: `bash logview.sh ERROR`
- Tùy chọn xem các dòng có từ ERROR hoặc WARNING: `bash logview.sh "ERROR|Warning"`

## 5. Force update time Linux 

```sh
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
```
