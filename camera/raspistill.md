Raspberry Pi native Camera Module (CSI port) with Raspbian binutils:

```bash
raspistill --nopreview -t 500 -w 1640 -h 1232 -q 30 -o /tmp/img_`date +"%Y-%m-%d_%H.%M.%S"`.jpg

# With iTerm2 Shell Integration installed:
raspistill --nopreview -t 500 -w 1640 -h 1232 -q 30 -o - | imgcat
```
