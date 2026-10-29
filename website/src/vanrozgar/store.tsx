import {createContext,useContext} from 'react';
import type {Req} from './requests/mock';

export type Modal=null|{t:'plant',k:string,vn?:string}|{t:'all'}|{t:'art',k:string}|{t:'swap',v?:string,id?:string}|{t:'drv'};
export type CartLine={k:string,v:string,n:number};
export type Profile={name:string,email:string,address:string,village:string};
export type App={
  role:string,setRole:(r:string)=>void,menu:boolean,setMenu:(b:boolean)=>void,
  cat:string,setCat:(c:string)=>void,allP:boolean,setAllP:(b:boolean)=>void,
  blk:string,setBlk:(c:string)=>void,srt:string,setSrt:(c:string)=>void,q:string,setQ:(c:string)=>void,
  metric:string,setMetric:(c:string)=>void,faq:number,setFaq:(n:number)=>void,jt:string,setJt:(c:string)=>void,
  sel:string,setSel:(c:string)=>void,toast:(t:string)=>void,modal:Modal,setModal:(m:Modal)=>void,
  openP:(k:string,vn?:string)=>void,swapStart:(v?:string,id?:string)=>void,
  reqs:Req[],setReqs:(f:(p:Req[])=>Req[])=>void,
  wish:string[],toggleWish:(k:string)=>void,cart:CartLine[],addCart:(k:string,v:string)=>void,setCart:(f:(p:CartLine[])=>CartLine[])=>void,
  phone:string,setPhone:(p:string)=>void,profile:Profile,setProfile:(p:Profile)=>void,
  theme:string,toggleTheme:()=>void,hash:string,cur:string,
};
export const Ctx=createContext<App>(null as any);
export const useApp=()=>useContext(Ctx);
