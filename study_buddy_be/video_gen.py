import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
import urllib.request
import uuid
import requests



driver = webdriver.Chrome()
def load():
    global driver

    driver.get("https://discord.gg/")

def prompt(prompt):
    prompt = prompt + " in anime style"
    global driver
    ids = []

    elements = driver.find_elements(By.TAG_NAME, 'form')
    for temp in elements:
        for e in temp.find_elements(By.TAG_NAME, 'div'):
            try:
                if e.get_attribute("role") == "textbox":
                    e.click()
                    time.sleep(0.5)
                    e.send_keys(Keys.CONTROL + "a")
                    e.send_keys(Keys.DELETE)

                    e.send_keys("/create")
                    time.sleep(1)
                    e.send_keys(" ", prompt, Keys.RETURN)
                    print("send")
            except:
                pass

    return prompt



def toggle():
    elements = driver.find_elements(By.CLASS_NAME, 'iconWrapper_de6cd1')
    for e in elements:
        if e.get_attribute("aria-label") == "Inbox":
            e.click()
            print("toggled")
def get_src(prompt):
    src = None

    while src == None:
        print("tried")
        elements = driver.find_elements(By.CLASS_NAME, 'message__04a5b')
        for temp in elements:
            for temp2 in temp.find_elements(By.CLASS_NAME, 'contents_d3ae0d'):
                if prompt in temp2.text:
                    print("gott")
                    for e in temp.find_elements(By.TAG_NAME, 'video'):
                        data = requests.get(e.get_attribute('poster')).content
                        img = "./static/" + str(uuid.uuid4()) + ".jpg"
                        f = open(img, 'wb')

                        f.write(data)
                        f.close()

                        print(e.get_attribute('src'))
                        data = requests.get(e.get_attribute('src')).content
                        vid = "./static/" + str(uuid.uuid4()) + ".mp4"
                        f = open(vid, 'wb')

                        f.write(data)
                        f.close()

                        src = {"img": img.replace("./", "/"), "vid": vid.replace("./", "/")}
                        print(src)

        time.sleep(15)


    return src

def scrollDown():
    try:
        elements = driver.find_elements(By.CLASS_NAME, 'scroller__1f96e')
        print(elements)
        elements[0].click()
        elements[0].send_keys(Keys.END)
    except:
        pass

