from bottle import route, run, template, request, static_file, url, get, post, response, error, abort, redirect, os
import sys
import json
import recommender as reco


@route("/")
def upload():
    return template("index")

@route('/upload', method='POST')
def do_upload():
    upload = request.files.get('upload')
    num = int(request.params.get('num', 5))
    print(type(num))
    if not upload.filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        return 'File extension not allowed!'
    img = upload.file.read()

    #upload.filename = "AaaaAAAAAAA.jpg"
    #upload.save("./img")
    #res = reco.similar_to(0, distance=True)
    #res = reco.decode("./img/"+upload.filename)
    res = reco.similar_to(img, num)
    response.headers['Content-Type'] = 'application/json'
    return json.dumps(res)

run(host="0.0.0.0", port=8000, debug=True, reloader=True)
