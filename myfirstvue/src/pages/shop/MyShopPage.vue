<template>
    <div class="page-shop">
        <div class="nav-title">前端小课</div>
        <span class="section-title">简介</span>
        <p class="des">
            《前端小课》是一本关于前端入门到进阶的多媒体电子书，通过公众号的形式呈现内容，并与粉丝形成互动．推动读者自我驱动，利用业余时间学习前端，迎合大前端的浪潮。
        </p>
        <span class="section-title">关于创办者</span>
        <p class="des">创办者，素燕，来自一线大厂互联网从业者，做过移到端开发，非常热爱大前端热爱跨平台技术，希望能够把前端技术灵活运用到移动端。</p>
        
        <span class="section-title">打开学习</span>
        <p class="des">
            目前共有<span>220+</span>名同学加入打卡学习队伍中，它们来自不同的领域，有is，Android和前端的小伙伴。添加微信wsy9871，备注小课，便会有人邀请加入微信群。
        </p>
        <div class="triangle"></div>
        <div class="icon"></div>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'shopPage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "购物车"
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

* {
    margin: 0;
    padding: 0;
}

.nav-title {
    color: black;
    text-align: center;
    font-weight: bold;
    font-size: 28px;
    border-bottom: 1px solid #dcdcdc;
}

.section-title {
    color: #258BD6;
    font-size: 18px;
    margin-left: 10px;
    border-bottom: 1px solid #258BD6;
}

p {
    margin-left: 10px;
    padding:20px 0 20px 0;
    color: black;
    font-size: 15px;
}

p>span {
    color: red;
}

.triangle {
      width: 0;
      /* width style */
      border: 20px solid;
      /* top [left, tight] bottom*/
      border-color: #f30 transparent transparent;
}

.icon {
    background-color: antiquewhite;
    width: 15px;
    height: 15px;
    border: 11px solid transparent;
}

</style>