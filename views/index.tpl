<html>
<head>
  <script src="https://unpkg.com/vue"></script>
  <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
  <script src="vue-spinner.js"></script>
  <link rel="shortcut icon" href="favicon.ico" />
</head>
<style>
button {
    font-size: 1.4em;
    font-weight: bold;
    padding: 10px 30px;
    background-color: #0082b3;
    color: #fff;
    border-style: none;
}
input[type=text] {
    width: 50%;
    padding: 12px 20px;
    font-size: 1.2em;
    margin: 8px 0;
    box-sizing: border-box;
}

input[type=number] {
    width: 10%;
    padding: 12px 20px;
    margin: 8px 0;
    font-size: 1.2em;
    box-sizing: border-box;
}


input[type=radio], input[type=checkbox] {
  display: none;
}

.radio, .checkbox {
  box-sizing: border-box;
  -webkit-transition: background-color 0.2s linear;
  transition: background-color 0.2s linear;
  position: relative;
  display: inline-block;
  margin: 0 20px 8px 0;
  padding: 12px 12px 12px 42px;
  border-radius: 8px;
  background-color: #f6f7f8;
  vertical-align: middle;
  cursor: pointer;
}
.radio:hover, .checkbox:hover {
  background-color: #009db3;
}
.radio:hover:after, .checkbox:hover:after {
  border-color: #0082b3;
}
.radio:after, .checkbox:after {
  -webkit-transition: border-color 0.2s linear;
  transition: border-color 0.2s linear;
  position: absolute;
  top: 50%;
  left: 15px;
  display: block;
  margin-top: -10px;
  width: 16px;
  height: 16px;
  border: 2px solid #bbb;
  border-radius: 6px;
  content: '';
}

.radio:before {
  -webkit-transition: opacity 0.2s linear;
  transition: opacity 0.2s linear;
  position: absolute;
  top: 50%;
  left: 20px;
  display: block;
  margin-top: -5px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #0082b3;
  content: '';
  opacity: 0;
}
input[type=radio]:checked + .radio:before {
  opacity: 1;
}

.checkbox:before {
  -webkit-transition: opacity 0.2s linear;
  transition: opacity 0.2s linear;
  position: absolute;
  top: 50%;
  left: 21px;
  display: block;
  margin-top: -7px;
  width: 5px;
  height: 9px;
  border-right: 3px solid #0082b3;
  border-bottom: 3px solid #0082b3;
  content: '';
  opacity: 0;
  -webkit-transform: rotate(45deg);
  -ms-transform: rotate(45deg);
  transform: rotate(45deg);
}
input[type=checkbox]:checked + .checkbox:before {
  opacity: 1;
}

#flabel {
  color: white;
  background-color: #0082b3;
  padding: 8px;
  border-radius: 12px;
}

div {
{ margin: 2px 50px; }
}

</style>
<body>
<H1>Image recommender </H1>
<p> Please upload a photo of clothes. </p>

<div id="app">
  <input type="radio" id="one" value="upload" v-model="picked">
  <label for="one" class="radio">upload a photo</label>
  <input type="radio" id="two" value="url" v-model="picked">
  <label for="two" class="radio">get from URL</label>
  <div v-if="picked == 'upload'">
    <label for="file_photo" id="flabel">
    +Select a photo <input @change="selectedFile" type="file" style="display:none;" id="file_photo">
    </label>
  </div>
  <div v-else>
    URL: <input type="text" v-model=url>
  </div>
  <div>
  Number: <input type="number" min="1" max="100" v-model="num">
  </div>
  <div>
  <button @click="search" type="submit" style="size:20">search</button>
  </div>
  <center>
    <grid-loader :loading="loading" :color="color" :size="size"></grid-loader>
  </center>
</div>
<div id="preview" >
  <img :src="img">
</div>
<ul id="example-1">
  <p v-if="items.length > 0">Result</p>
  <li v-for="item in items" style="display: inline-block;">
    <img :src="item.url" />
  </li>
</ul>
<div>
</body>
<script>
(function(){
    var PulseLoader = VueSpinner.PulseLoader
    var GridLoader = VueSpinner.GridLoader
    let preview = new Vue({
      delimiters: ['${', '}'],
      el: '#preview',
      data: {
        img: ""
      }
    });
    let resultList = new Vue({
      delimiters: ['${', '}'],
      el: '#example-1',
      data: {
        items: []
      }
    });
    new Vue({
        el: '#app',
        data: {
            uploadFile: null,
            num: 5,
            picked: "upload",
            url: "",
            color: "blue",
            size: "20",
            loading: false
        },
        components: {
          'PulseLoader': PulseLoader,
          'GridLoader': GridLoader
        },
        methods: {
            selectedFile: function(e) {
                e.preventDefault();
                reader = new FileReader()
                let files = e.target.files;
                this.uploadFile = files[0];

                reader.onload = e => {
                  preview.img = e.target.result;
                  resultList.items = []
                };
                reader.readAsDataURL(this.uploadFile);

            },
            search: function() {
              if (this.picked == "upload"){
                let formData = new FormData();
                if (this.uploadFile){
                  console.log(this.uploadFile.name);
                  console.log(this.num);
                  formData.append("upload", this.uploadFile);
                  formData.append("num", this.num);
                  let config = {
                    headers: {
                        'content-type': 'multipart/form-data'
                    }
                  };
                  this.loading = true;
                  axios.post('upload', formData, config)
                    .then(response => {
                      console.log(response.data);
                      resultList.items = response.data
                      this.loading = false;
                    })
                    .catch(error => {
                      this.loading = false;
                    })
                }else{
                  alert("Please select a photo.");
                }

              } else {
                preview.img = this.url
                this.loading = true;
                axios.get("search/url", {
                  params: {
                    url: this.url,
                    num: this.num
                  }
                })
                .then(response => {
                  console.log(response.data);
                  resultList.items = response.data
                  this.loading = false;
                })
                .catch(error => {
                  this.loading = false;
                })
              }
          }
        }
    });
})();
</script>
</html>
