import type {Lang} from '../lang';
import ui from './ui';
import home from './home';
import places from './places';
import plants from './plants';
import forms from './forms';
import requests from './requests';
import modals from './modals';
import details from './details';

/* One row per string: [English, Hindi, Marathi]. Numbers are written as {n}; {w} is a slot that is translated on its own. */
export type Row=[string,string,string];
const ALL:Row[]=[...ui,...home,...places,...plants,...forms,...requests,...modals,...details];

const NUM=/\d[\d,]*(?:\.\d+)?/g;
const TOK=/(\{w\}|\{n\})/;
const esc=(s:string)=>s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
export type Slot={re:RegExp,kinds:string[],t:string};
const cache:Partial<Record<Lang,{exact:Map<string,string>,slots:Slot[]}>>={};

export function build(l:Lang){
  if(cache[l])return cache[l]!;
  const idx=l==='hi'?1:2;
  const exact=new Map<string,string>(),slots:Slot[]=[];
  for(const r of ALL){
    const key=r[0].replace(NUM,'{n}').trim(),val=r[idx];
    if(key.includes('{w}')){
      const parts=key.split(TOK);
      const re=new RegExp('^'+parts.map(p=>p==='{w}'?'(.+?)':p==='{n}'?'(\\d[\\d,]*(?:\\.\\d+)?)':esc(p)).join('')+'$');
      slots.push({re,kinds:parts.filter(p=>p==='{w}'||p==='{n}'),t:val});
    }else exact.set(key,val);
  }
  return cache[l]={exact,slots};
}
