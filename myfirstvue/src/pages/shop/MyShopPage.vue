<template>
    <div class="moments">
        <div class="header">
        </div>
        <div id="my-info">
                <span>天那边</span>
                <div id="header-icon"></div>
        </div>
        <div class="coments-item" v-for="i in 3" v-bind:key="i">
            <div class="user-header"></div>
            <div class="container">
                <p class="user-title">互帮互助</p>
                <p class="content">纪念《前端小课》第二阶段课程圆满结束，这一阶段主要搞定CSS布局。以实现一个朋友圈为实践。你说CSS牛不牛。</p>
                <div class="pic-container">
                    <div></div>
                    <div></div>
                    <div></div>
                    <div></div>
                    <div></div>
                    <div></div>
                    <div></div>
                </div>
                <div class="time-action">
                    <p class="time-indicator">2小时前</p>
                    <div class="more-action"></div>
                </div>
                <div class="active-container">
                    <div class="prais">

                    </div>
                    <div class="comments">

                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'shopPage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "购物车",
            cover:require('../../assets/moments/cover.png'),
        }
    },
     methods: {
         clickScroll() {
             let fbox = document.getElementById("f")
             if(fbox) {
                 let left = fbox.offsetLeft
                 let navBox = document.getElementById("nav-box")
                 if (navBox) {
                     navBox.scrollTo(navBox.clientWidth / 2 - fbox.clientWidth / 2 - 15, 0)
                 }
             }
         }
     }
}
</script>

<style scoped>

@media screen and (min-width: 500px) {
    .moments {
        width: 500px;
    }
}

.moments {
    padding-bottom: 60px;
}

.header {
    height: 300px;
    background-image: url('../../assets/moments/cover.png');
    background-position: center;
    background-size: cover;
    margin-bottom: 40px;
}

#my-info {
    /* float: right; */
    margin-right: 20px;
    display: flex;
    justify-content: end;
    align-items: center;
    position: absolute;
    top: calc(env(safe-area-inset-bottom, 0px) + 275px);
    right: 0px;
}

#my-info span {
    color: white;
    padding-right: 20px;
    padding-bottom: 10px;
}

#header-icon {
    height: 60px;
    width: 60px;
    background-image: url('../../assets/moments/my.jpg');
    background-size: 60px 60px;
    border-radius: 10px;
}

.coments-item {
    margin: 10px 20px 0px 20px;
    display: flex;
    border-bottom: 1px solid #eeeeee;
    padding-bottom: 10px;
}

.user-header {
    width: 60px;
    height: 60px;
    background-image: url('../../assets/moments/1.png');
    background-size: contain;
    flex-shrink: 0;
    border-radius: 5px;
    margin-right: 10px;
}

.user-title {
    margin-top: 0px;
    margin-bottom: 0px;
    padding-top: 5px;
    font-size: 18px;
    color: cadetblue;
}

.content {
    margin: 10px 0px 10px 0px;
    font-size: 16px;
    color: black;
    line-height: 25px;
}

.pic-container {
    display: grid;
    grid-template-rows: repeat(3,1fr);
    grid-template-columns: repeat(3, 1fr);
    grid-gap: 10px;
}

.pic-container div {
    width: 80px;
    height: 80px;
}

.pic-container div:nth-child(1) {
    background-image: url('../../assets/moments/2.png');
    background-size: cover;
    background-position: center;
}

.pic-container div:nth-child(2) {
    background-image: url('../../assets/moments/3.png');
    background-size: cover;
    background-position: center;
}

.pic-container div:nth-child(3) {
    background-image: url('../../assets/moments/4.png');
    background-size: cover;
    background-position: center;
}

.pic-container div:nth-child(4) {
    background-image: url('../../assets/moments/1.png');
    background-size: cover;
    background-position: center;
}


.pic-container div:nth-child(5) {
    background-image: url('../../assets/moments/2.png');
    background-size: cover;
    background-position: center;
}

.pic-container div:nth-child(6) {
    background-image: url('../../assets/moments/3.png');
    background-size: cover;
    background-position: center;
}


.pic-container div:nth-child(7) {
    background-image: url('../../assets/moments/4.png');
    background-size: cover;
    background-position: center;
}

.time-action {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.time-indicator {
    color: lightgray;
    padding: 10px 0px 10px 0px;
    font-size: 14px;
}

.more-action {
    width: 40px;
    height: 25px;
    background-image: url('../../assets/moments/star.png');
    background-size: contain;
    background-repeat: no-repeat;
    background-position: center;
}


.active-container {
    height: 60px;
    background-color: antiquewhite;
}
</style>