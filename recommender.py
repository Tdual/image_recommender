import numpy as np
import scipy
import scipy.spatial
import os
import pickle
import operator
import tensorflow as tf
from glob import glob

file_dir = os.path.abspath(os.path.dirname(__file__))
MODEL_PATH = file_dir+'/obj/classify_image_graph_def.pb'

with open(file_dir+"/obj/features.pickle", mode='rb') as f:
   features = pickle.load(f)

with open(file_dir+"/obj/img_name.pickle", mode='rb') as f:
   img_name = pickle.load(f)


def get_image_names():
    # imgs = glob(os.path.join("./images", "*.jpg"))
    imgs = np.sort(img_name)
    return imgs

def similar_to(img_data, num=5):
    feature = decode(img_data)
    images = get_image_names()
    sims = [{
        "id": images[k].split("/")[-1],
        "url": "https://s3-ap-northeast-1.amazonaws.com/image-recommender/test/"+images[k].split("/")[-1],
        "similarity": round(1 - scipy.spatial.distance.cosine(feature, v), 3)}
        for k,v in enumerate(features)]
    return sorted(sims, key=lambda o: o["similarity"], reverse=True)[:num]

def show_sim_image(img_id):
    id_list = similar_to(img_id, distance=True)
    fig, axs = plt.subplots(1, len(id_list), figsize=(20, 3))
    for i, id in enumerate(id_list):
        print(id)
        img =imread(imgs[id[0]])
        axs[i].imshow(img)
        axs[i].axis('off')
    plt.show()

def decode(img_data):
    with tf.gfile.FastGFile(MODEL_PATH, 'rb') as f:
        graph_def = tf.GraphDef()
        graph_def.ParseFromString(f.read())
        tf.import_graph_def(graph_def, name='')

    with tf.Session() as sess:
        pool3 = sess.graph.get_tensor_by_name('pool_3:0')
        #image_data = tf.gfile.FastGFile(filename, 'rb').read()
        pool3_features = sess.run(pool3,{'DecodeJpeg/contents:0': img_data})
        feature = np.squeeze(pool3_features)
    return feature
