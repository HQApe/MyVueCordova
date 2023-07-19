<template>
    <div class="tab-bar-item" :style="activeStyle" @click="onItemClicked">
        <div v-if="!isActive">
            <slot name="item-icon"></slot>
        </div>
        <div v-else>
            <slot name="item-icon-active"></slot>
        </div>
        <div :class="{active:isActive}">
            <slot name="item-text"></slot>
        </div>
    </div>
</template>


<script>
export default {
    name:'TabBarItem',
    props: {
        path: {
            type:String,
            required:true
        },
        activeColor: {
            type:String,
            default: '#0ec3f4'
        }
    },
    computed: {
        isActive() {
            return this.$route.path.indexOf(this.path) !== -1
        },

        activeStyle() {
            return this.isActive ? {color:this.activeColor} : {}
        }
    },
    methods: {
        onItemClicked() {
            this.$router.push(this.path)
        }
    }
}
</script>

<style scoped>
.tab-bar-item {
    flex: 1;
    text-align: center;
    height: 49px;
    font-size: 14px;
}

.tab-bar-item img {
    width: 24px;
    height: 24px;
    margin-top: 3px;
    vertical-align: middle;
    margin-bottom: 2px;
}
</style>