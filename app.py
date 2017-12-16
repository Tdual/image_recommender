from bottle import route, run, template, request, static_file, url, get, post, response, error, abort, redirect, os
from bottle import HTTPResponse
import sys
import json
import logging
import requests

import recommender as reco

file_dir = os.path.abspath(os.path.dirname(__file__))

logger = logging.getLogger('LoggingTest')
logger.setLevel(10)
fh = logging.FileHandler(os.path.join(file_dir,"logs", "test.log"))
logger.addHandler(fh)
sh = logging.StreamHandler()
logger.addHandler(sh)
formatter = logging.Formatter('%(asctime)s:%(lineno)d:%(levelname)s:%(message)s')
fh.setFormatter(formatter)
sh.setFormatter(formatter)


def response_json(body, status=200):
    response = HTTPResponse(body=body, status=status)
    response.headers["Content-Type"] = "application/json"
    return response

@get('/media/:path#.+#')
def server_static(path):
    return static_file(path, root=os.path.join(file_dir, "views"))

@route("/")
def upload():
    return template("index")

@get('/favicon.ico')
def get_favicon():
    return server_static('favicon.ico')

@get('/example.png')
def get_image():
    return server_static('example.png')

@get('/vue-spinner.js')
def get_spinner():
    return server_static("vue-spinner.js")

@route('/upload', method='POST')
def do_upload():

    upload = request.files.get('upload')
    num = int(request.params.get('num', 5))
    if num > 1000:
        body = {"message": "limit of number.", "code": 0}
        return response_json(body, status=500)

    logger.info("request numuber of images: {}".format(num))
    if not upload.filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        return 'File extension not allowed!'
    img = upload.file.read()

    try:
        res = reco.similar_to(img, num)
    except Exception as e:
        logger.error(e)
        body = {"message": "could not get similar images.", "code": 2}
        return response_json(body, status=500)
    body = json.dumps(res)
    return response_json(body, status=200)

@route('/search/url', method='GET')
def get_images():
    res = None
    url = request.params.get("url", "")
    num = int(request.params.get('num', 5))
    if num > 1000:
        body = {"message": "limit of number.", "code": 0}
        return response_json(body, status=400)
    logger.info(url)

    try:
        r = requests.get(url)
    except Exception as e:
        logger.error(e)
        body = {"message": "could not find a image.", "code": 1}
        return response_json(body, status=400)

    try:
        img = r.content
        res = reco.similar_to(img, num)
    except Exception as e:
        logger.error(e)
        body = {"message": "could not get similar images.", "code": 2}
        return response_json(body, status=500)

    if res:
        body = json.dumps(res)
        return response_json(body, status=200)
    else:
        body = {"message": "could not get similar images.", "code": 2}
        return response_json(body, status=500)
    #resp.content_type = 'image/png'
    #resp.set_header('Content-Length', str(len(r.content)))
    #return resp


run(host="0.0.0.0", port=8000, debug=True, reloader=True)
