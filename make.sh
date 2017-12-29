echo ";-------ASSEMBLING------------------------------------------------------;"
rgbasm -o snkbin.obj -p 255 main.asm;
echo ""
echo ";-------LINKING---------------------------------------------------------;"
rgblink -p 255 -o snkbin.gb -n snkbin.sym snkbin.obj;
echo ""
echo ";-------FIXING----------------------------------------------------------;"
rgbfix -v -p 255 snkbin.gb
echo ""

cp snkbin.gb "/Users/yvar/Library/Application Support/com.miller.bgb_149327856815280/drive_c/winebottler/snake.gb"

cp snkbin.sym "/Users/yvar/Library/Application Support/com.miller.bgb_149327856815280/drive_c/winebottler/snake.sym"
