+++
Description = "Golang 一门新的编程语言"
Tags = ["development","golang"]
date = "2017-05-05T11:22:27+08:00"
title = "golang intro"
+++


## golang 入门介绍
RT   


cd themes
git clone https://github.com/jaden/twentyfourteen
Step 4: Make some basic configuration changes

The file named config.toml in your site directory contains the global configuration for your Hugo site. Edit the file with a text editor to make some basic configuration changes as listed below. Remember to replace the values according to your specific conditions.

baseurl = "http://[YourSiteIP]/"
languageCode = "en-us"
title = "Your Site Name"
theme = "twentyfourteen"
Step 5: Compose your content

In your site directory, input the following command to create a content page in the directory ~/mysite/content/post/.

cd ~/mysite/
hugo new post/about.md
Open the file in a text editor, the format of the file should resemble the following.

+++
date = "2015-12-25T03:21:23Z"
draft = true
title = "about"

+++
Between the two lines of +++ lies the meta information about your content page. Here, you can remove the line draft = true and modify the title line as you wish.

Under the second +++ line, add the content that you want to display on the web page. Remember to write your content in the Markdown language.

## This is an H2 headline

Text goes here.
After finishing this edit, keep the text editor open for later use.

Step 6: Adjust your content with the Hugo server

You can use Hugo's built-in web server to deploy your site, which can instantaneously display your changes on the web page as soon as you modify your content in a text editor.

Open another terminal, configure the iptables rules to allow your access to your site on Hugo server's default port 1313:

sudo iptables -I INPUT -p tcp --dport 1313 -j ACCEPT
Launch the Hugo server:

hugo server --bind="[YourServerIP]"
Visit your site from a browser:

http://[YourServerIP]:1313
Now, you can try to edit the content of the page file in the previous terminal or add/remove a page file. You will find that any modifications in the content/ directory will be reflected simultaneously on your browser screen. This is a great feature for a busy blogger because you can always immediately see your modifications for better composing experiences.

After you finish your edit, press Ctrl+C to stop the Hugo server.

Step 7: Publish your site

Now it is time to publish your site on the web. Run the following commands and Hugo will generate all of the static content suitable for publishing within the public/ directory.

cd ~/mysite
hugo
Note: Hugo will not delete old files which were generated previously when you run the commands above. In order to avoid unexpected results, you can always delete the public/ directory before you run the hugo command or specify a new output destination as shown in the following command.

hugo --destination=public2
Since the Nginx web server has already been running on the server, all you need to do is copy the content of the ~/mysite/public/ directory or other custom destination directories to your web directory /usr/share/nginx/html/.

Delete the original files:

cd /usr/share/nginx/html/
sudo rm -rf background.jpg index.php logo.png
Copy your static site files to the web directory:

cd ~/mysite/public
sudo cp -R ~/mysite/public/. /usr/share/nginx/html/
That's it. Now you can visit your super fast static site from your browser: http://[YourServerIP].

To see more details, use the command hugo help or visit the Hugo official website.
