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

    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'HomePage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "首页",
            message:'Hello',
            password:'',
            sex:'男',
            hobbies:[]
        }
    },
    methods:{
        onclicked() {

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
</style>