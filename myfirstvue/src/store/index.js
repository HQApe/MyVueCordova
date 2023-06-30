import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
    state: {
        counter:0, 
        students:[
          {id:1101, name:"jacky", age:18},
          {id:1102, name:"nancy", age:20},
          {id:1103, mame:"judy", age:19},
          {id:1104, name:"alon", age:21}
        ],
        info: {
          name: "sandy",
          age:35,
          height: 1.88
        }
    },
    mutations: {
        increase(state) {
            state.counter++
        },
        decrease(state) {
            state.counter--
        },
        increaseCount(state, playload) {
          state.counter += playload
        },
        addStudent(state, stu) {
          state.students.push(stu)
        },
        updateInfo(state, height) {
          state.info.height = height
        }
    },
    getters:{
      powerCounter(state) {
        return state.counter * state.counter
      },
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
    },
    actions:{
      increase(context, playload) {
        setTimeout(() => {
          context.commit('increaseCount', playload)
        }, 1000);
      }
    },
    modules:{}
})

export default store