<template>
    <div class="page-home">
      <div id="nav">
        <div id="nav-left">
          <div id="nav-more"></div>
          <p>前端小课</p>
        </div>
        <div id="navi-right">
          <p>给读者的一封信</p>
          <p>学习资源</p>
          <p>前端学习路线</p>
          <div id="free-book">
            <p>免费订阅</p>
            <div id="notice"></div>
          </div>
          <p>GitHub</p>
        </div>
      </div>
      <div id="content">
        <div class="section header">
          <div id="book-info">
            <div id="book-img"></div>
            <p>《前端小课》</p>
            <p>一本免费多媒体电子书，从零开始学习前端技术，帮助10W人入门并进阶前端。</p>
            <p>王素燕 / 著</p>
          </div>
          <div id="book-about">
            <p>关于本书</p>
            <p id="book-intr">前端小课是通过图片、文字、代码、视频等多种方式写成的一本多媒体电子书。全书分为不同的小书，每本小书旨在讲透一个知识点，比如 CSS布局、HTML、动画。以最基础的编程知识为起点，即使不懂编程的小白也能够通过本书学会编程，顺利进入互联网行业。
本书最大的特色是通过公众号+图书+网站形成一个闭环。读者可通过公众号实时获得最新的前端知识，并与作者实时互动；通过图书可以系统地学习前端知识；通过网站可看到代码实时运行结果，真正的所见即所得。</p>
            <button id="book-now">立即阅读</button>
          </div>
        </div>
        <div class="section book"></div>
        <div class="section tools"></div>
      </div>
      <div id="bottom"></div>
    </div>
</template>

<script>



export default {
    name:'HomePage',
    data () {
        return {
            title: "首页"
        }
    },
    methods:{
    },
  computed: {
          
  }
}
</script>

<style scoped>

.page-home {
    display: flex;
    background-color: #efefef;
    flex-direction: column;
    align-items: center;
  }

/*匹配带有屏幕的设备，只适用于屏幕超过 1200px的设备 */
@media screen and (min-width: 1200px) {
  #content {
    width: 1200px;
  }
  #nav-left {
    width: 250px;
    display: flex;
    justify-content: flex-start;
    flex-shrink: 0;
  }
}

@media screen and (min-width: 850px) {
  #nav-more {
    visibility: hidden;
  }
  #nav-left {
    justify-content: space-between;
  }
}

/*匹配带有屏幕的设备，只适用于屏幕低于 800px的设备 */
@media screen and (max-width: 850px) {
  .header {
    flex-direction: column;
  }

  #navi-right {
    visibility: hidden;
  }

  #nav-more {
    visibility: visible;
  }

  #nav-left {
    justify-content: flex-start;
  }
}

#nav {
  background-color: white;
  height: 44px;
  width: 100%;
  display: flex;
  position:fixed;
  /**如果要顶满安全区的状态栏，需要设置top=0 */
  top: 0;
  padding-top: env(safe-area-inset-top, 0px) ;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #ececec;
}

#content {
  padding-top: 44px;
}

#bottom {
  height: 200px;
  width: 100%;
  background-color: antiquewhite;
  margin-top: 20px;
  margin-bottom: calc(env(safe-area-inset-bottom, 0px) + 49px);
}

.section {
  background-color: white;
  margin-left: 20px;
  margin-right: 20px;
  margin-top: 20px;
  border-radius: 10px;
}

#nav-left {
  width: 250px;
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

#nav-left p {
  font-size: 22px;
  margin-right: 40px;
}

#nav-more {
  margin-left: 20px;
  margin-right: 20px;
  width: 50px;
  height: 44px;
  background-color: #ececec;
}

#navi-right {
  display: flex;
  width: 600px;
  margin-right: 20px;
  flex-shrink: 0;
  justify-content: space-between;
}

/* 给文字后面添加图片 */
#navi-right p:last-child::after {
  content: '';
  background-image: url('../../assets/moments/star_small.png');
  display: inline-block;
  margin-left: 5px;
  width: 15px;
  height: 15px;
  vertical-align: middle;
  background-position: center;
  background-size: contain;
  background-repeat: no-repeat;
}

#free-book {
  display: flex;
  /*父相子绝 */
  position: relative;
}

#notice {
  background-color: red;
  width: 5px;
  height: 5px;
  border-radius: 2.5px;
  position: absolute;
  top: 15px;
  right: -5px;
}

.header {
  display: flex;
  align-items: center;
}

#book-info {
  width: 200px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-left: 20px;
}

#book-info p {
  margin: 10px;
}

#book-info p:nth-child(2) {
  font-size: 20px;
  font-weight: bold;
}

#book-info p:nth-child(3) {
  font-size: 14px;
}

#book-info p:nth-child(4) {
  font-size: 10px;
}


#book-img {
  background-image: url('https://z3.ax1x.com/2021/04/11/c0KRBj.png');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  background-clip: content-box;
  width: 200px;
  height: 200px;
}

#book-about {
  padding-top: 50px;
  padding-right: 20px;
  padding-bottom: 50px;
  align-self: flex-start;
  display: flex;
  flex-direction: column;
  margin-left: 60px;
}

#book-about p:first-child {
  font-size: 25px;
  font-weight: bold;
}

#book-intr {
  margin: 0px;
  font-size: 18px;
  line-height: 25px;
}

#book-now {
  background-color: rgba(53, 130, 238, 0.929);
  color: white;
  font-size: 18px;
  align-self: flex-start;
  padding: 10px 30px 10px 30px;
  margin-top: 20px;
  margin-bottom: 20px;
  border: none;
  border-radius: 5px;
}

.book,.tools {
  height: 300px;
  background-color: antiquewhite;
}

</style>