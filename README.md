# Init

Download a theme and push it into the repository:

```
# 2015/10/28
git clone git@github.com:daniel-e/blog.git
cd blog.git
wget -O beautiful-jekyll.zip https://github.com/daattali/beautiful-jekyll/archive/master.zip
unzip beautiful-jekyll.zip
mv beautiful-jekyll-master/ src
echo "source 'https://rubygems.org'" > src/Gemfile
echo "gem 'github-pages'" >> src/Gemfile

git add beautiful-jekyll.zip src
git commit -m "initial import"
git push
```

Create a docker image

```
cp ~/.ssh/id_rsa .     # security?
cp ~/.ssh/id_rsa.pub .
cp id_rsa.pub authorized_keys
sudo ~/docker/docker build -t jekyll/init .
```

# Customize

sudo ~/docker/docker run -t -i -p 4000:4000 -p 4022:22 -v /tmp:/host jekyll/init

ssh zz@localhost -p 4022
git clone git@github.com:daniel-e/blog.git
cd blog.git/src

[modify the files]

sudo bundle update
bundle exec jekyll serve

