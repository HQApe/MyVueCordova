import {get, post, download} from './http'

//设置具体调用的接口路径和提供给App.vue的方法。
export const logIn=(params)=>post("/auth/login", params)

export const logOut=(params)=>get("/auth/logout", params)

export const getProjectList=(data)=>get("/api/project/list", data)

export const downloadFile=(url,params={})=>download(url, params)