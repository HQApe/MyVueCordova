<template>
    <div class="page-home">
        <div class="my-navigation-bar">
            首页
            <button class="item-more" @click="onclicked">More</button>
        </div>
        <p>
            <!-- router-link标签属性 -->
            <router-link :to="'/detail/' + 20123">导航去详情</router-link>
        </p>
        <input type="text" v-model.lazy="message"/>
        <input type="text" v-model.trim="password"/>
        <p>输入的内容{{ message + '===' + password }}</p>
        <label for="male">
            <input type="radio" id="male" value="男" v-model="sex"/>男
        </label>
        <label for="female">
            <input type="radio" id="female" value="女" v-model="sex"/>女
        </label>
        <p>选择的性别是：{{ sex }}</p>
        <h2>爱好：</h2>
        <div class="hobbies">
            <input type="checkbox" value="篮球" v-model="hobbies"/>篮球
            <input type="checkbox" value="足球" v-model="hobbies"/>足球
            <input type="checkbox" value="乒乓球" v-model="hobbies"/>乒乓球
            <input type="checkbox" value="羽毛球" v-model="hobbies"/>羽毛球
            <h3>爱好是：{{ hobbies }}</h3>
        </div>
        <div id="dynamic-component-demo">
            <button
                v-for="tab in tabs"
                v-bind:key="tab"
                v-bind:class="['tab-button', { active: currentTab === tab }]"
                v-on:click="currentTab = tab"
            >
                {{ tab }}
            </button>

            <keep-alive>
                <component v-bind:is="currentTabComponent" class="tab"></component>
            </keep-alive>
        </div>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

var tabA = {
    name:"tab-posts",
    data: function() {
          return {
            posts: [
              {
                id: 1,
                title: "Cat Ipsum",
                content:
                  "<p>Dont wait for the storm to pass, dance in the rain kick up litter decide to want nothing to do with my owner today demand to be let outside at once, and expect owner to wait for me as i think about it cat cat moo moo lick ears lick paws so make meme, make cute face but lick the other cats. Kitty poochy chase imaginary bugs, but stand in front of the computer screen. Sweet beast cat dog hate mouse eat string barf pillow no baths hate everything stare at guinea pigs. My left donut is missing, as is my right loved it, hated it, loved it, hated it scoot butt on the rug cat not kitten around</p>"
              },
              {
                id: 2,
                title: "Hipster Ipsum",
                content:
                  "<p>Bushwick blue bottle scenester helvetica ugh, meh four loko. Put a bird on it lumbersexual franzen shabby chic, street art knausgaard trust fund shaman scenester live-edge mixtape taxidermy viral yuccie succulents. Keytar poke bicycle rights, crucifix street art neutra air plant PBR&B hoodie plaid venmo. Tilde swag art party fanny pack vinyl letterpress venmo jean shorts offal mumblecore. Vice blog gentrify mlkshk tattooed occupy snackwave, hoodie craft beer next level migas 8-bit chartreuse. Trust fund food truck drinking vinegar gochujang.</p>"
              },
              {
                id: 3,
                title: "Cupcake Ipsum",
                content:
                  "<p>Icing dessert soufflé lollipop chocolate bar sweet tart cake chupa chups. Soufflé marzipan jelly beans croissant toffee marzipan cupcake icing fruitcake. Muffin cake pudding soufflé wafer jelly bear claw sesame snaps marshmallow. Marzipan soufflé croissant lemon drops gingerbread sugar plum lemon drops apple pie gummies. Sweet roll donut oat cake toffee cake. Liquorice candy macaroon toffee cookie marzipan.</p>"
              }
            ],
            selectedPost: null
          };
        },
        template: `
  	<div class="posts-tab">
      <ul class="posts-sidebar">
        <li
          v-for="post in posts"
          v-bind:key="post.id"
          v-bind:class="{ selected: post === selectedPost }"
					v-on:click="selectedPost = post"
        >
          {{ post.title }}
        </li>
      </ul>
      <div class="selected-post-container">
      	<div
        	v-if="selectedPost"
          class="selected-post"
        >
          <h3>{{ selectedPost.title }}</h3>
          <div v-html="selectedPost.content"></div>
        </div>
        <strong v-else>
          Click on a blog title to the left to view it.
        </strong>
      </div>
    </div>
  `
}

var tabB = {
    name:"tab-archive",
    template: "<div>Archive component <input type='text'/></div>"
}

export default {
    name:'HomePage',
    components:{MyNavigationBar, tabA, tabB},
    data () {
        return {
            title: "首页",
            message:'Hello',
            password:'',
            sex:'男',
            hobbies:[],
            currentTab: "A",
          tabs: ["A", "B"]
        }
    },
    methods:{
        onclicked() {
            new Promise((resolve, reject)=>{
                
                setTimeout(() => {
                    resolve('Hello World')
                }, 1000);

            }).then((result) => {
                console.log(result);
                return result + '11111'
            }).then((result) => {
                console.log(result);
                return result + '22222'
            }).then((result) => {
                console.log(result);
            }).catch((err) => {
                console.error(err);
            });
        }
    },
  computed: {
          currentTabComponent: function() {
            return "tab" + this.currentTab;
          }
        }
}
</script>

<style scoped>
.my-navigation-bar {
    height: 45px;
    line-height: 45px;
    text-align: center;
    background-color: #1d7bff;
    color: #fff;
    top: 0;
    left: 0;
    right: 0;
    padding-top: env(safe-area-inset-top, 0px) ;
}

.my-navigation-bar .item-more {
    margin-right: 0;
}

.tab-button {
  padding: 6px 10px;
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
  border: 1px solid #ccc;
  cursor: pointer;
  background: #f0f0f0;
  margin-bottom: -1px;
  margin-right: -1px;
}
.tab-button:hover {
  background: #e0e0e0;
}
.tab-button.active {
  background: #e0e0e0;
}
.tab {
  border: 1px solid #ccc;
  padding: 10px;
}
.posts-tab {
  display: flex;
}
.posts-sidebar {
  max-width: 40vw;
  margin: 0;
  padding: 0 10px 0 0;
  list-style-type: none;
  border-right: 1px solid #ccc;
}
.posts-sidebar li {
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
  cursor: pointer;
}
.posts-sidebar li:hover {
  background: #eee;
}
.posts-sidebar li.selected {
  background: lightblue;
}
.selected-post-container {
  padding-left: 10px;
}
.selected-post > :first-child {
  margin-top: 0;
  padding-top: 0;
}
</style>