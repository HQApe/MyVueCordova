<template>
    <div class="page-categories">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f" @showup="clickedDown"></my-navigation-bar>
        <div class="zhq-strategy">
            <div class="zhq-title">
                信用卡攻略
            </div>
            <div>查看更多》</div>
        </div>
        <div class="zhq-list">
            <div class="zhq-item" v-for="n in 20" v-bind:key="n" v-on:click="onItemClicked(n)">
                <div class="left-icon-box">
                    <img src="https://avatars.githubusercontent.com/u/18701895?v=4" alt="">
                </div>
                <div class="right-box">
                    <div class="name">那些条件决定了贷款买房贷款额度呢?那些条件决定了贷款买房贷款额度呢那些条件决定了贷款买房贷款额度呢那些条件决定了贷款买房贷款额度呢那些条件决定了贷款买房贷款额度呢?那些条件决定了贷款买房贷款额度呢?</div>
                    <div class="time">爱吃fei鱼 01-30</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'CategoriesPage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "分类",
            items:[{id:1},{id:2}]
        }
    },
    methods: {
        onItemClicked (n) {
            alert("You are clicked"+ n)
        },
        clickedDown(event){
            alert("You are clicked"+ event)
            // 调用cordova插件
            MNfc.startScan({
                "onStart":function() {
                    console.log('onStart');
                },
                "onScan":function(data){
                    console.log(data);
                },
                "onClose":function() {
                    console.log('onClose');
                },
                "onError":function(err) {
                    console.log("errCode:" + err.errCode + "errMsg:" + err.errMsg);
                }
            });
        }
    }
}
</script>


<style scoped>
.page-categories {
    padding-top: 44px;
    padding-bottom: 45px;
}

.zhq-strategy {
    display: flex;
    position: sticky;
    top: 45px;
    padding-top: 10px;
    height: 35px;
    width: 100%;
    background: white;
    justify-content: space-between;
    border-bottom: 0.5px solid lightgray;
}

.zhq-list {
    /* padding-top: 45px; */
}

.zhq-strategy .zhq-title {
    display: flex;
    margin-top: 0px;
    margin-left: 16px;
    margin-right: 16px;
    margin-bottom: 10px;
}

.zhq-item {
    display: flex;
    border-bottom: 0.5px solid lightgray;
}

.zhq-item .left-icon-box {
    flex: 50px 50px 100px 100px;
    background-color: red;
}

.zhq-item .left-icon-box img {
    width: 80px;
    height: 80px;
    margin-top: 0px;
    margin-left: 16px;
}

.zhq-item .right-box {
    flex: 1;
}

.zhq-item .right-box .name {
    margin-top: 10px;
    margin-left: 10px;
    margin-right: 20px;
    font-size: 16px;
    color: black;
    height: 40px;

    text-align: left;
    line-height: 20px;
    overflow:hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    text-overflow: ellipsis;
    -webkit-box-orient: vertical;
}

.zhq-item .right-box .time {
    display: flex;
    margin-top: 10px;
    margin-left: 10px;
    margin-bottom: 10px;
    font-size: 14px;
}
</style>