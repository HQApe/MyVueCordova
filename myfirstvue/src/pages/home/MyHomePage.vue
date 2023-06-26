<template>
    <div class="page-home">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>

        <div id="tab-bar">
            <div class="tab-bar-item">首页</div>
            <div class="tab-bar-item">分类</div>
            <div class="tab-bar-item">购物车</div>
            <div class="tab-bar-item">我的</div>
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
            title: "首页"
        }
    },
    methods:{
        onTest() {

        }
    }
}
</script>

<style scoped>
@import url("../../assets/base.css");
.page-home {
    background: red;
    display: flex;
    position: fixed;
    top: 0px;
    left: 0px;
    right: 0px;
    bottom: 0px;
}

#tab-bar{
    display: flex;
    background: #f6f6f6;
    position: fixed;
    left: 0px;
    right: 0px;
    bottom: 10px;
    box-shadow: 0px -1px 7px rgb(100,100,100,0.2);
}
.tab-bar-item{
    flex:1;
    text-align: center;
    height:49px;
    padding-right: 20px;
    margin-left: 20px;
    background-color: blue;
}
</style>