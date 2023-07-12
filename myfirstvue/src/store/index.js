import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
    modules:{
      count:{
        state: {
          // modules的形式在访问时，仅state需要加state.moduleName.property
          counter:0
        },
        mutations:{
          // 无论是否是modules形式，在外面使用时，this.$store.commit('method',params...)方式触发
          increase(state) {
            state.counter++
          },
          decrease(state) {
            state.counter--
          },
          increaseCount(state, playload) {
            state.counter += playload
          },
        },
        getters: {
          // 无论是否是modules形式，在外面使用时，$store.getters.method(params)方式触发
          powerCounter(state) {
            return state.counter * state.counter
          }
        },
        actions:{
          // 无论是否是modules形式，在外面使用时，this.$store.dispatch('method', params...)方式触发
          increase(context, playload) {
            setTimeout(() => {
              context.commit('increaseCount', playload)
            }, 1000);
          }
        },
      },
      student:{
        state:{
          students:[
            {id:1101, name:"jacky", age:18},
            {id:1102, name:"nancy", age:20},
            {id:1103, mame:"judy", age:19},
            {id:1104, name:"alon", age:21}
          ]
        },
        mutations: {
          addStudent(state, stu) {
            state.students.push(stu)
          },
          updateInfo(state, height) {
            state.info.height = height
          }
        },
        getters: {
          more20stu(state) {
            return state.students.filter(s=> s.age > 20)
          },
          more20stuLength(state, getters) {
            return getters.more20stu.length
          },
          moreAgeStu(state) {
            return age=>{
              return state.students.filter(s=>s.age>age)
            }
          }
        }
      }
    },
    state: {
        info: {
          name: "sandy",
          age:35,
          height: 1.88
        }
    },
    mutations: {

    },
    getters:{

    },
})

export default store