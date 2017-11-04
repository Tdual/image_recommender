<html>
<head>
  <script src="https://unpkg.com/vue"></script>
  <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
  <script src="vue-spinner.js"></script>
  <link rel="shortcut icon" href="favicon.ico" />
</head>
<body>
<H1>Image recommender </H1>
<p> Please upload a photo of clothes. </p>

<div id="app">
  <input type="radio" id="one" value="upload" v-model="picked">
  <label for="one">upload a photo</label>
  <input type="radio" id="two" value="url" v-model="picked">
  <label for="two">get from URL</label>
  <div v-if="picked == 'upload'">
    photo: <input @change="selectedFile" type="file">
  </div>
  <div v-else>
    URL: <input type="text" v-model=url>
  </div>
  number: <input type="number" min="1" max="100" v-model="num">
  <br>
  <button @click="search" type="submit">search</button>
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
