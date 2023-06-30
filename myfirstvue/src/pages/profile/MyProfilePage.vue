<template>
    <div class="page-profile">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>
        <button @click="increase">增加</button>
        <button @click="decrease">减少</button>
        <div>Main div State with Store: <strong>{{ this.$store.state.counter }}</strong></div>
        <button @click="addStudent">添加学生</button>
        <my-counter></my-counter>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

let MyCounter = {
    name:"Counter",
    template:`
    <div>Sub div State Manager With Store: 
        <strong>{{ this.$store.state.counter }}</strong>
        <h2>counter*counter: {{$store.getters.powerCounter}}</h2>
        <h2>{{$store.getters.more20stu}}</h2>
        <h2>{{$store.getters.more20stuLength}}</h2>
        <h2>{{$store.getters.moreAgeStu(25)}}</h2>
    </div>
    `
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
            this.$store.dispatch('increase', 5)
        },
        decrease() {
            this.$store.commit('decrease')
        },
        addStudent() {
            const stu = {id:1105, name:"Helon", age:28}
            this.$store.commit('addStudent', stu)
        }
    }
}
</script>

<style scoped>
.page-profile {
    margin-top: 44px;
}
</style>