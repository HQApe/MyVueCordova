<template>
    <div class="gods-detail">
        <!-- <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar> -->
        <p class="my-params">{{$route.params.goodsId}}</p>
        <div>
            <span class="section section-title stiky-box">FlexBox学习（上）</span>
            <div class="section section-box">
                <div id="mystyle">前端之巅</div>
                <div>iOS王道</div>
                <div>Android无敌</div>
            </div>
        </div>
        <div>
            <span class="section section-title stiky-box">FlexBox学习下</span>
            <div class="section section-flex">
                <div>我要学习前端</div>
                <div>我要学习CSS Layout</div>
                <div>我要学习JavaScript</div>
            </div>
        </div>
        
        <div>
            <span class="section section-title stiky-box">Web流式布局了解下</span>
            <div class="section section-web">
                <p>我是一个p标签</p>
                <p>我也是一个p标签</p>
                <p>我还是一个p标签</p>
                <p>我是p<span>我是span标签</span>and<span>我是span标签</span></p>
            </div>
        </div>
        
        <div>
            <span class="section section-title stiky-box">position相对布局了解下</span>
            <div class="section relative">
                <div>我要学习前端</div>
                <div>我要学习CSS Layout</div>
                <div>我要学习JavaScript</div>
            </div>
        </div>
        
        <div>
            <span class="section section-title stiky-box" >Grid布局了解下</span>
            <div class="section-grid grid">
                <div>Vue</div>
                <div>CSS</div>
                <div>JavaScript</div>
                <div>Android</div>
                <div>PHP</div>
                <div>Python</div>
                <div>Java</div>
            </div>
        </div>

        <div>
            <span class="section section-title stiky-box">Grid进阶布局了解下</span>
            <div class="section-house">
                <div class="huayuan">花园</div>
                <div class="caiyuan">菜园</div>
                <div class="house">房子</div>
                <div class="rest_area">休息区</div>
                <div class="guoyuan">果园</div>
                <div class="tree">树</div>
            </div>
        </div>
        
        <div>
            <span class="section section-title stiky-box">Grid-area布局了解下</span>
            <div class="house-area">
                <div class="huayuan">花园</div>
                <div class="caiyuan">菜园</div>
                <div class="house">房子</div>
                <div class="rest_area">休息区</div>
                <div class="guoyuan">果园</div>
                <div class="tree">树</div>
            </div>
        </div>
        
        <div>
            <span class="section section-title stiky-box">Grid-area布局了解下</span>
            <div class="aligns">
                <div class="huayuan">花园</div>
                <div class="caiyuan">菜园</div>
                <div class="house">房子</div>
                <div class="rest_area">休息区</div>
                <div class="guoyuan">果园</div>
                <div class="tree">树</div>
            </div>
        </div>
        <div>
            <span class="section section-title stiky-box">Float布局了解下</span>
            <div class="float">
                <div class="huayuan">花园</div>
                <div class="caiyuan">菜园</div>
                <div class="house">房子是我国经济的支柱产业，必须要稳定楼市，让人们买得起房，住得起房，敢买房</div>
                <div class="rest_area">休息区</div>
                <div class="guoyuan">果园</div>
                <div class="tree">树</div>
            </div>
        </div>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'godsDetail',
    components:{MyNavigationBar},
    data () {
        return {
            title: "详情"
        }
    }
}
</script>

<style scoped>

.gods-detail {
    padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 49px);
}

.my-params {
    /* margin-top: 50px; */
    margin-left: 10px;
    height: 20px;
}

.section,.section-grid {
    margin-top: 20px;
    margin-left: 10px;
    margin-right: 10px;
    margin-bottom: 10px;
}

.section-title {
    color: #258BD6;
    font-size: 18px;
    border-bottom: 1px solid #258BD6;
}

.section>div {
    background-color: blue;
    color: white;
    padding: 10px;
}

#mystyle {
    height: 50px;
    align-self: self-start;
}

.section-box {
    display: flex;
    flex-direction: row;
    height: 200px;
    background-color: antiquewhite;
    /* justify-content: flex-start; */
    /* justify-content: flex-end; */
    /* justify-content: space-around; */
    /* justify-content: space-between; */
    justify-content: space-evenly;
    /* justify-content: center; */
    /* align-items: flex-start;
    align-items: flex-end; */
    align-items: center;
    /* align-items: baseline; */
    /* align-items: stretch; */
}

.stiky-box {
    /*如果sticky的是同一父类的同级元素，则会叠加覆盖
    不同父类的，则会随着父类的划过，而隐藏该sticky
    */
    background-color: white;
    position: sticky;
    top: 0px;
    left: 0px;
    z-index: 2;
}


.section-flex {
    display: flex;
    background-color: #eeeeee;
    width: 600px;
    height: 200px;
}

.section-flex div {
    height: 40px;
    color: white;
    font-size: 16px;
    font-weight: bold;
    text-align: center;
    /* flex-basis: 0; */
    flex-grow: 1;
    display: flex;
    flex-direction: row;
    /*水平居中 */
    justify-content: center;
    /*垂直居中 */
    align-items: center;
}

.section-flex div:nth-child(1) {
    background-color: red;
    flex-shrink: 0;
    /* flex-grow: 3; */
}

.section-flex div:nth-child(2) {
    background-color: black;
    width: 300px;
    flex-grow: 3;
    flex-shrink: 1;
}

.section-flex div:nth-child(3) {
    background-color: purple;
    flex-grow: 2;
    width: 200px;
    flex-shrink: 2;
}

.section-web p {
    padding: 10px;
    background-color: cyan;
    line-height: 40px;
    text-align: left;
    border: 2px solid blue;
}

.section-web p:nth-child(2) {
    background-color: yellow;
}

.section-web p span {
    display: block;
    background-color: red;
}

.relative {
    position: relative;
}

.relative div:nth-child(1) {
    background-color: red;
    /* 相对于窗口，悬浮在窗口上 */
    /* position: fixed; */
    /* bottom: 60px;
    z-index: 1; */
}

.relative div:nth-child(2) {
    background-color: black;
    /*相对于自身左上角，原始位置保留，不会影响Web容器的大小 */
    position: absolute;
    top: 5px;
    bottom: 5px;
    left: 5px;
    right: 5px;
}

.relative div:nth-child(3) {
    background-color: purple;
    /* height: 50px; */
    /* 还会受父元素的position影响，不会保留原始位置，会覆盖其它元素 */
    /* position: absolute;
    left: 10px;
    bottom: 10px; */
}

.grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    grid-template-rows: repeat(3, 1fr);
    grid-gap: 5px 10px;
}

.grid div {
    background-color: #258BD6;
}


.section-house {
    margin: 20px 10px 10px 10px;
    background-color: #eeeeee;
    display: grid;
    grid-gap: 10px;
    grid-template-columns: repeat(8, 1fr);
    grid-template-rows: repeat(9, 30px);
    grid-auto-rows: 60px;
}

.section-house>.house {
    background-color: cornflowerblue;
    grid-row: 3 / -3;
    grid-column: 3 / -3;
}

.section-house>.huayuan {
    background-color: brown;
    grid-row: 8 / -1;
    grid-column: 3 / -3;
}

.section-house>.caiyuan {
    background-color: aquamarine;
    grid-row: 1 / 3;
    grid-column: 1 / -3;
}

.section-house>.rest_area {
    background-color: bisque;
    grid-row: 3 / -1;
    grid-column: 1 / 3;
}

.section-house>.guoyuan {
    background-color: palevioletred;
    grid-row: 1 / -1;
    grid-column: -3 / -1;
}

.section-house>.tree {
    background-color: green;
    grid-row: 10 / 11;
    grid-column: 1 / -1;
}

.house-area {
    margin: 20px 10px 10px 10px;
    background-color: #eeeeee;
    display: grid;
    grid-template-columns: repeat(8,1fr);
    grid-template-rows: repeat(9, 40px);
    grid-auto-rows: 40px;
    grid-gap: 10px;
    grid-template-areas: 
        "caiyuan caiyuan caiyuan caiyuan caiyuan caiyuan guoyuan guoyuan"
        "caiyuan caiyuan caiyuan caiyuan caiyuan caiyuan guoyuan guoyuan"
        "rest_area rest_area house house house house guoyuan guoyuan"
        "rest_area rest_area house house house house guoyuan guoyuan"
        "rest_area rest_area house house house house guoyuan guoyuan"
        "rest_area rest_area house house house house guoyuan guoyuan"
        "rest_area rest_area house house house house guoyuan guoyuan"
        "rest_area rest_area huayuan huayuan huayuan huayuan guoyuan guoyuan"
        "rest_area rest_area huayuan huayuan huayuan huayuan guoyuan guoyuan"
        ". . tree tree tree tree . .";
}

.house-area>.huayuan {
    background-color: brown;
    grid-area: huayuan;
}
.house-area>.caiyuan {
    background-color: cadetblue;
    grid-area: caiyuan;
}
.house-area>.house {
    background-color: cornflowerblue;
    grid-area: house;
}
.house-area>.rest_area {
    background-color: darksalmon;
    grid-area: rest_area;
}
.house-area>.guoyuan {
    background-color: hotpink;
    grid-area: guoyuan;
}
.house-area>.tree {
    background-color: green;
    grid-area: tree;
}

.aligns {
    width: 400px;
    height: 200px;
    background-color: #eeeeee;
    margin: 20px 10px 10px 10px;
    display: grid;
    grid-template-columns: 100px 100px;
    grid-template-rows: 40px 40px;
    grid-auto-rows: 40px;
    /*以下是相对cell */
    /*水平 */
    justify-items: stretch;
    /*垂直 */
    align-items: stretch;
    /*以下是相对于grid区域*/
    /*水平 */
    justify-content: end;
    /*垂直 */
    align-content: end;
    gap: 5px;
}

.aligns div {
    /* height: 30px; */
    /* width: 80px; */
    display: flex;
    justify-content: center;
    align-items: center;
}

.aligns .house {
    grid-row: 1 / 2;
    grid-column: 1 / 3;
    background-color: #258BD6;
    /*自生在cell中的水平和垂直对齐 */
    justify-self: center;
    align-self: center;
}

.aligns .huayuan {
    background-color: aqua;
}

.aligns .caiyuan {
    background-color: aquamarine;
}

.aligns .rest_area {
    background-color: antiquewhite;
}

.aligns .guoyuan {
    background-color: rosybrown;
}

.aligns .tree {
    background-color: green;
}

.float {
    margin: 20px 10px 10px 10px;
    height: 600px;
    background-color: #eeeeee;
}

.float .huayuan {
    margin: 10px;
    height: 40px;
    width: 80px;
    background-color: #258BD6;
    float: left;
}
.float .caiyuan {
    background-color: antiquewhite;
    height: 30px;
}

.float .house {
    background-color: aquamarine;
    padding: 10px;
    /*清除该元素及其之后的元素受float的影响 */
    /* clear: left; */
}

</style>