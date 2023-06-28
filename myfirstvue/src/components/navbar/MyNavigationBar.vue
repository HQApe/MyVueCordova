<template>
    <div class="my-navigation-bar" :style="{backgroundColor:backgroud, color:color}">
        {{title}}
        <button class="item-more" v-on:click="onclicked">More</button>
    </div>
</template>


<script>
export default {
    name:'MyNavigationBar',
    props: {
        backgroud:String,
        color: {
            type: String,
            default: '#fff'
        },
        title:{
            type: String,
            required: true
        }
    },
    methods: {
        onclicked() {
            this.$emit('showup', this.$parent.title)
        }
    }
}
</script>>

<style scoped>
.my-navigation-bar {
    height: 45px;
    line-height: 45px;
    text-align: center;
    background-color: #1d7bff;
    color: #fff;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    padding-top: env(safe-area-inset-top, 0px) ;
    z-index: 2;
}

.my-navigation-bar .item-more {
    margin-right: 0;
}
</style>