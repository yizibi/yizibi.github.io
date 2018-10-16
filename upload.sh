# This script file is a upload git local repository to github.
#
# Make sure this file is in '/' and than you can double-click to use this file(GNU/Linux).
#
# Or use command "sh GitUpload.sh"
#
# Make sure your bash terminal resolution must be large.Because something need a large terminal resolution.
#
# This script file is created by SunboossRS.
# His GitHub- https://github.com/yizibi
# His blog(Chinese)- https://yizibi.github.io/
#
# Now this upload script file is default to my "workspace"file.If you want to use,plz delete "cd .." and get it into "/" .
# 自动上传新的代码到仓库,需要输入更新的文本,默认push 到 master

#cd ..
echo " _______    ________   ________"
echo "|  _____|  |___  ___| |__    __|"
echo "| |  ____     |  |       |  |"
echo "| | |_  _|    |  |       |  |"
echo "| |___| |   __|  |__     |  |"
echo "|_______|  |________|    |__|"
echo " _      _    _______    _           ________     ______    _____"
echo "| |    | |  |  __   |  | |         |  ____  |   |  __  |  |  __ |"
echo "| |    | |  | |__|  |  | |         | |    | |   | |__| |  | |  | |"
echo "| |    | |  |  ____|   | |         | |    | |   |  __  |  | |   | |"
echo "|  \__/  |  | |        | |______   | |____| |   | |  | |  | |__| |"
echo " \______/   |_|        |________|  |________|   |_|  |_|  |_____|"
echo ""
echo "---------------------------------------------------------------------------"
#cd ..
git pull origin master
echo ""
echo ""

echo "我们需要你提供一下更新留言，马上就可以结束。"
echo "只不过，希望你打出来的字不要有删除修改，否则，在项目里的更新留言可能会出现像 �[D 这样的字符。"
echo ""
read -p "你的输入 >"

git add .

git stage .

git commit -a -m "${REPLY}"

git status

git gc

git push

echo "感谢使用我们的上传工具!"
echo " __________   _      _    _______    _      _   _    _        _       _"
echo "|____   ___| | |    | |  |  ___  |  | \    | | | |  / /      | |     | |"
echo "     | |     | |____| |  | |___| |  |  \   | | | |_/ /       | |     | |"
echo "     | |     |  ____  |  |  ___  |  | | \  | | |  _ |        | |     | |"
echo "     | |     | |    | |  | |   | |  | |\ \ | | | | \ \       | |     | |"
echo "     | |     | |    | |  | |   | |  | | \ \| | | |  \ \      |  \___/  |"
echo "     |_|     |_|    |_|  |_|   |_|  |_|  \___| |_|   \_\      \_______/"

echo "请稍等 ...我们正在进行最后一次推送检验..."
git pull origin master

clear

echo "运行完毕"
