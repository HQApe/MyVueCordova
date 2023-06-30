<template>
    <div class="page-profile">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>
        <button @click="increase">增加</button>
        <button @click="decrease">减少</button>
        <div>Main div State with Store: <strong>{{ this.$store.state.counter }}</strong></div>
        <my-counter></my-counter>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

let MyCounter = {
    name:"Counter",
    template:"<div>Sub div State Manager With Store: <strong>{{ this.$store.state.counter }}</strong></div>"
}

export default {
    name:'ProfilePage',
    components:{MyNavigationBar, MyCounter},
    data () {
        return {
            title: "我的"
        }
    },
    methods: {
        increase() {
            this.$store.commit('increase')
        },
        decrease() {
            this.$store.commit('decrease')
        }
    }
}
</script>

<style scoped>
.page-profile {
    margin-top: 44px;
}
</style>