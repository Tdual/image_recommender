<html>
<head>
  <script src="https://unpkg.com/vue"></script>
  <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
</head>
<body>
<H1>Image recommender </H1>

<div id="app">
    <input @change="selectedFile" type="file">
    <button @click="upload" type="submit">search</button>
</div>
<div id="preview">
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
            uploadFile: null
        },
        methods: {
            selectedFile: function(e) {
                e.preventDefault();
                reader = new FileReader()
                let files = e.target.files;
                this.uploadFile = files[0];

                reader.onload = e => {preview.img = e.target.result;};
                reader.readAsDataURL(this.uploadFile);

            },
            upload: function() {
                let formData = new FormData();
                console.log(this.uploadFile.name);
                formData.append("upload", this.uploadFile);
                let config = {
                    headers: {
                        'content-type': 'multipart/form-data'
                    }
                };
                axios.post('upload', formData, config)
                    .then(function(response) {
                        console.log(response);
                        console.log(resultList);
                        resultList.items = response.data
                    })
                    .catch(function(error) {
                    })
            }
        }
    });
})();
</script>
</html>
