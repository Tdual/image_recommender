from bottle import route, run, template, request, static_file, url, get, post, response, error, abort, redirect, os
import sys
import json
import logging

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


@get('/media/:path#.+#')
def server_static(path):
    return static_file(path, root=os.path.join(file_dir, "views"))

@route("/")
def upload():
    return template("index")

@get('/favicon.ico')
def get_favicon():
    return server_static('favicon.ico')

@route('/upload', method='POST')
def do_upload():

    upload = request.files.get('upload')
    num = int(request.params.get('num', 5))
    logger.info("request numuber of images: {}".format(num))
    if not upload.filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        return 'File extension not allowed!'
    img = upload.file.read()

    try:
        res = reco.similar_to(img, num)
    except Exception as e:
        logger.error("##############")
        logger.error(e)
        logger.error("##############")
    response.headers['Content-Type'] = 'application/json'
    return json.dumps(res)

run(host="0.0.0.0", port=8000, debug=True, reloader=True)
