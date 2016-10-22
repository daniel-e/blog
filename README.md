# Create a new blog

```bash
wget -O beautiful-jekyll.zip https://github.com/daattali/beautiful-jekyll/archive/master.zip
unzip beautiful-jekyll.zip
mv beautiful-jekyll-master blog

docker build -t jek/1 .
docker run -t -i -p 4000:4000 --net=host -v $PWD/blog:/blog jek/1
cd /blog
bundle install
```

Commit the changes to a new docker image. For that execute the following commands in the host.

```bash
docker ps                           # to get the container id
docker commit <container id> jek/2
```

In docker do

```bash
bundle exec jekyll serve
```

Go to a browser and open `localhost:4000`. A page should be visible.

# Update a blog

Now you can edit your blog on the host. When finished, create a new site.

```bash
docker run -t -i -p 4000:4000 --net=host -v $PWD/blog:/blog jek/2
cd /blog
bundle update
# if there were updates you could commit the changes
# docker ps
# docker commit <container id> jek/2
jekyll serve
jekyll build
```

# Publish
```bash
rsync _site/* ~/Dropbox/github/blog/
```

# Create screenshots from papers

```bash
convert -resize 220x -background white -alpha remove paper.pdf output.png
```

