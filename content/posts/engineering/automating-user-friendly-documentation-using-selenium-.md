---
title: "Automating user-friendly documentation with Selenium"
draft: false
author: Samantha G. Zeitlin
---


Once upon a time, a friend recruited me to do some technical writing for the company where he works now. Basically, they needed someone to quickly revise and update the documentation for their software. 

Most modern user-friendly software documentation isn't just writing, though. It's screenshots. A LOT of screenshots. So you don't just write "click on the blue box", you also show a picture of it, like this. See the blue box? 


----------


If you want to upload a file, first click on the blue box labeled "Upload File". 

![Screen Shot 2014-09-03 at 3.51.27 PM.png](/site_media/media/f67a27be33bc1.png)


----------
## Why bother with documentation? ##

The truth is, nobody really likes writing documentation (ok maybe not nobody, but most engineers don't enjoy doing it). 

Personally, I find that having the screenshots actually helps me spell out each of the steps I need to describe. Otherwise, I'm tempted to skip ahead or assume the user will figure it out. 

*(Hint: eventually, they will figure it out, but the longer it takes, the more they will hate your software.)* 

Ideally, good documentation can stand alone, even if your app typically includes some kind of user training or tutorial. Employees are going to come and go, and as a user of many different kinds of software, I've always appreciated the cases where I could actually refer to the manual when I couldn't remember something I hadn't done in a long time, or if I needed to do something different from the usual workflow. 


----------


## Manual Labor: Worthwhile, but boring ##

I did the first round of revisions on the existing documentation entirely by hand. Taking useful screenshots means selecting the area you want to show, by clicking and dragging. Making those screenshots more useful means annotating them, usually with some kind of verbal cue to denote the part that's relevant to the text description. 


The previous version of the documentation was using red circles, boxes, and arrows, so I had to keep it consistent. For many of the screenshots, I was again manually clicking and dragging to create the relevant shape in the right location, like this:

![Screen Shot 2014-09-03 at 3.47.10 PM.png](/site_media/media/7b91ebae33bc1.png)

Then I had to upload the images to Google Drive and insert them into the appropriate locations in the Google Doc draft, and edit the text accordingly. 


At the end of the first day, I had created something like 29 screenshots. I continued working on that part of the project for several days, averaging about 20 screenshots per day. 


----------


Once I had a draft, I had to wait for the company experts to review my work and make sure what I had written was actually accurate. 


I had questions about terminology that had been chosen because it worked in conversation, but sometimes the same objects were being referred to by different names, which is confusing to users. In other cases, sub-objects and container objects had the same name, when they needed to be referenced more specifically. I wrote these kinds of questions in comments and tagged the appropriate parties. 

And waited. 


----------
## Asking For Help: Worthwhile ##

While I was waiting, I had a conversation with one of the engineers. It went something like this:

**Me**: Boy, my wrist hurts already. I am not looking forward to doing the rest of the screenshots by hand. I'm wondering if there's some way to automate that part of the project. 

**Him**: Why don't you use Selenium?

**Me** *(overjoyed)*: Oh, I saw a [really cool talk][1] about using Selenium for QA, so I know there's a python wrapper and it can do screenshots. Have you done that before for this sort of thing?

**Him**: No, but I don't see any reason why you can't. 

**Me**: If I have any questions, can I ask you for help?

**Him** *(shrugging)*: You can try! 

----------

For my first attempt at using Selenium, I found [this blog post][2], and followed the example to use a list of URLs with the web driver via the python wrapper. 

This essentially worked, although the hard part turned out to be logging into the system. Although Selenium is supposed to stay logged in, for some reason it wasn't doing that, so I had to include some code in case it logged itself back out between steps. 

I also wanted to have a cute way to use part of the URL to name the resulting screenshots, so my code looked something like this: 

[code lang="python"]
    def log_in(url, userName, password, url_list_file = "url_list.txt"):
        '''
        log in
        call the screenshot function as described in [Caleb Thorne's blogpost][3]
        save to a .png file
        '''

        browser = webdriver.Firefox()

        count = 0 #use this to avoid over-writing screenshot files with the same fragment name

        with open (url_list_file) as url_list:
            for url in url_list:
                 count+=1
                #if username and password slots are in the page, fill them in
                print url
                browser.get(url)
                time.sleep(5)
                try:
                    element = browser.find_element_by_name("username")
                    element.send_keys(userName)
                    element = browser.find_element_by_name("password")
                    element.send_keys(password)
                    element.send_keys(Keys.RETURN)
                    time.sleep(5) #wait to make sure it has time to authenticate login

                except selenium.common.exceptions.ElementNotVisibleException:
                    print "don't need to log back in again, going on"

                link_parts = urlparse.urlsplit(url)
                file_title = link_parts.fragment
                print file_title
                trunc = cleaned_frag(file_title)
                png_name = trunc + str(count) + '.png'
                take_screenshot(browser, png_name, 'screenshots')
                print "shot " + png_name

        return
    [/code] 


----------

But then I got stuck. The URLs for this site were kind of strange, and I wasn't sure why. Also, some parts of the pages didn't seem to have unique URLs, so I wasn't sure how to distinguish them, or how to be sure I was getting all the screenshots I needed. 

Then I learned that because of the way the site was set up, I couldn't access all of the parts that I needed without clicking on them. The good news is, Selenium has a way to do this for you.  

I asked one of the other engineers, since someone said he had used Selenium with the site already.

Initially, he didn't understand what I was asking or why, and he seemed kind of annoyed that I was asking him anything. Since it wasn't his job to help me write code and I didn't want to bother him, I asked someone else if they could just point me in the right direction. I think that person must have said something to the first guy, because eventually, he came back and asked what was going on, and then he was a huge help. 

So after some digging, I learned that because this company uses a '[thick layer][4]' for their site, I had to tell Selenium where to click in order to access many parts of the application. I'm showing an example of the type of thing I wrote (not an actual piece of the code). 


----------
[code lang="python"]
    def nav_to_item(item_name):
        """run this to show this section, how to do one of the steps, and take screenshots.
        returns: 3 screenshots."""

        browser.find_element_by_link_text(item_name).click()
        time.sleep(3)
        take_screenshot(browser, 'item_name.png', 'path/folder')
    
        next_thing = browser.find_element_by_class_name("thing_name")
        scroll_to(next_thing)
        time.sleep(3)
        take_screenshot(browser, 'thing_name.png', 'path/folder')

        next_thing.click()
        take_screenshot(browser, 'thing_action.png', 'path/folder')

    return
    [/code]

By doing this, I learned a lot about how the site was put together. It seemed like different parts had been built at different times, in different ways, by different people, because although it all looked the same to the user, the objects underneath were specified in myriad different ways. 

This was a great learning opportunity for me, since it meant I got to try a bunch of different ways to point Selenium at different kinds of web objects. And it motivated me to go back and learn more CSS, jquery, and javascript. 


----------


Ultimately, probably nobody else at the company will use the code I wrote, but it saved me a lot of manual labor, which in turn saved me from further aggravating my over-moused wrist. 

The final version of the script can do about 50 screenshots in less than a minute. I can't do that many that fast, even if I wanted to clench my mouse in my fist and race the computer. So I think it was worth writing the code. 

When the app gets updated, the code should only require minor tweaks to maintain its usefulness. And if the site is overhauled so that the code becomes more consistent, the navigation tools can be significantly condensed. 




  [1]: https://speakerdeck.com/pycon2014/advanced-techniques-for-web-functional-testing-by-julien-phalip
  [2]: http://www.calebthorne.com/python/2012/May/taking-screenshot-webdriver-python
  [3]: http://www.calebthorne.com/python/2012/May/taking-screenshot-webdriver-python
  [4]: http://www.techterms.com/definition/thickclient
