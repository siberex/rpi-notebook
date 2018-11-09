# Pi Notebook

Various recipes for Raspberry Pi


# Camera module (CSI port)

Get image (native resolution is 3280 × 2464):

	raspistill --nopreview -t 500 -w 1640 -h 1232 -q 30 -o - | imgcat
	
	raspistill --nopreview -t 500 -w 1640 -h 1232 -q 30 -o /tmp/img_`date +"%Y-%m-%d_%H.%M.%S"`.jpg
	
	