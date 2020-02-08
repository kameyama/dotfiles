# dotfiles


## usage

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/switch-m/dotfiles/master/bootstrap.sh)"
```

インストールするとhttpsでcloneされるためパスワード入力が必要となります。  
ノンパスのsshに変更したい場合は下記を実行してください。  

```
cd $DOTFILES_PATH
git remote set-url origin $(git config --get remote.origin.url | sed -e "s/https:\/\/github\.com\//git@github.com:/g")
```


## 更新時

Brewfileやdotfileを追加した場合など、下記を実行して反映させます。  

```
$DOTFILES_PATH/bootstrap.sh
```


## 個人のgithubプロジェクトにdotfilesを持っていない方の作業

### 個人のgithubプロジェクトにdotfilesを作成する
個人のgithubプロジェクトに本リポジトリをpublic権限で作成します。  
理由は、curl + bootstrapでセットアップできるようにと、github actionsを使っているため。  

> *リポジトリには、パスワード文字列やシークレットファイルや.ssh/configなど  
> セキュリティ問題に繋がりそうなものは絶対にコミットしないでください。*  

本作業を行うためにはssh agentができgitのnameとemailが設定されていることが前提です。

```
cd $HOME
git clone git@github.com:switch-m/dotfiles.git
cd dotfiles
rm -rf .git
git init
git add .
git commit -m "first commit"

# GITHUB_USERNAMEを変更してから実行
git remote add origin git@github.com:GITHUB_USERNAME/dotfiles.git

git push -u origin master
```

下記のように、README.md & bootstrap.shのgithubのプロジェクト名を変更しcommit & pushしてください。  

```diff
❯ git diff
diff --git a/README.md b/README.md
index 74c78f7..ea94040 100644
--- a/README.md
+++ b/README.md
@@ -4,7 +4,7 @@
 ## usage

\```
-/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/switch-m/dotfiles/master/bootstrap.sh)"
+/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/fumimaron9/dotfiles/master/bootstrap.sh)"
\```

 インストールするとhttpsでcloneされるためパスワード入力が必要となります。
diff --git a/bootstrap.sh b/bootstrap.sh
index 5000c85..81a6bd4 100755
--- a/bootstrap.sh
+++ b/bootstrap.sh
@@ -5,7 +5,7 @@ umask 0022
 DOTFILES_PATH=$HOME/dotfiles

 if [ ! -d "$DOTFILES_PATH" ]; then
-  git clone https://github.com/switch-m/dotfiles.git "$DOTFILES_PATH"
+  git clone https://github.com/fumimaron9/dotfiles.git "$DOTFILES_PATH"
 else
   echo "INFO: doffiles already exists."
   echo
```

動作確認を行います。  

```
cd $HOME

# 先ほど作成したdotfilesを一旦削除する
rm -rf $DOTFILES_PATH/dotfiles

# GITHUB_USERNAMEを変更してから実行
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GITHUB_USERNAME/dotfiles/master/bootstrap.sh)"
```


### switch-m/dotfilesを上流ブランチ設定し取り込む

switch-m/dotfilesに更新が入るため取り込めるようにする。  

```
cd $DOTFILES_PATH

git remote add upstream git@github.com:switch-m/dotfiles.git

# エラーが出ないことを確認する
git pull --allow-unrelated-histories upstream master
```
