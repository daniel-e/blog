# Init

The following steps show how to create a new blog from scratch. First, we need to create a new repository on GitHub. Then, we download a theme and push it into the repository. This has been done as follows and needs to be done only once.

```bash
# 2015/10/28
git clone git@github.com:daniel-e/blog.git
cd blog
wget -O beautiful-jekyll.zip https://github.com/daattali/beautiful-jekyll/archive/master.zip
unzip beautiful-jekyll.zip
mv beautiful-jekyll-master/ src
echo "source 'https://rubygems.org'" > src/Gemfile
echo "gem 'github-pages'" >> src/Gemfile

git add beautiful-jekyll.zip src
git commit -m "initial import"
git push
```

Now, we create a docker image which we use in the future to write new posts.

```bash
cp ~/.ssh/id_rsa .     # security?
cp ~/.ssh/id_rsa.pub .
cp id_rsa.pub authorized_keys
sudo docker build -t jekyll/init .
```

We now have a docker image which we can use to create the blog. The advantage of this solution is that it is reproducible.

# Customize

```bash
sudo ~/docker/docker run -t -i -p 4000:4000 -p 4022:22 -v /tmp:/host jekyll/init

ssh zz@localhost -p 4022
git clone git@github.com:daniel-e/blog.git
cd blog/src

[modify the files]

# look for updates
sudo bundle update

# test the blog
# http://localhost:4000
bundle exec jekyll serve
```

# Publish

```bash
git clone git@github.com:daniel-e/daniel-e.github.io.git
rsync -rv _site/* daniel-e.github.io/
cd daniel-e.github.io/
git add -A
git commit -m "new post"
git push
...
```

# Useful links

* http://jekyllthemes.org/
* https://help.github.com/articles/using-jekyll-with-pages/
* http://jekyllrb.com/docs/github-pages/

