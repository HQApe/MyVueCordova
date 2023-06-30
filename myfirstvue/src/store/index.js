import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
    state: {
        counter:0
    },
    mutations: {
        increase(state) {
            state.counter++
        },
        decrease(state) {
            state.counter--
        }
    },
    getters:{},
    actions:{},
    modules:{}
})

export default store