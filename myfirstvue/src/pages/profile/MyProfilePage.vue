<template>
    <div class="page-profile">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'ProfilePage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "我的"
        }
    }
}
</script>