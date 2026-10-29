import {createContext,useCallback,useContext,useEffect,useMemo,useState,ReactNode} from 'react';
import en from './en';
import hi from './hi';
import mr from './mr';

export type Lang='en'|'hi'|'mr';
export type Vars=Record<string,string|number>;
export type TFn=(text:string,vars?:Vars)=>string;

/* code, short label for the header switch, full name */
export const LANGS:[Lang,string,string][]=[['en','EN','English'],['hi','हिं','हिन्दी'],['mr','मर','मराठी']];
export const PACKS:Record<Lang,any>={en,hi,mr};
const KEY='vanrozgar_lang';

let current:Lang='en';
export const getLang=()=>current;
const read=():Lang=>{try{const v=localStorage.getItem(KEY);if(v==='hi'||v==='mr'||v==='en')return v}catch{}return 'en'};

/* Texts are looked up by their English wording. A text with no entry stays in English. */
export function translate(lang:Lang,text:string,vars?:Vars){
  let s:string=PACKS[lang].ui[text]??text;
  if(vars)s=s.replace(/\{(\w+)\}/g,(m,k)=>k in vars?String(vars[k]):m);
  return s;
}

type Ctx={lang:Lang,setLang:(l:Lang)=>void,t:TFn};
const C=createContext<Ctx>({lang:'en',setLang:()=>{},t:(x,v)=>translate('en',x,v)});

export function useLangState():Ctx{
  const [lang,set]=useState<Lang>(read);
  current=lang;
  const setLang=useCallback((l:Lang)=>{set(l);try{localStorage.setItem(KEY,l)}catch{}},[]);
  useEffect(()=>{document.documentElement.lang=lang},[lang]);
  const t=useCallback<TFn>((x,v)=>translate(lang,x,v),[lang]);
  return useMemo(()=>({lang,setLang,t}),[lang,setLang,t]);
}
export const LangProvider=C.Provider;
export const useLang=()=>useContext(C);
export const useT=()=>useContext(C).t;

/* Text with link slots, for example "I agree to the {terms} and the {privacy}" */
export function useTParts(){
  const t=useT();
  return (text:string,parts:Record<string,ReactNode>):ReactNode[]=>
    t(text).split(/(\{\w+\})/).map((s,i)=>{const m=s.match(/^\{(\w+)\}$/);return m&&m[1] in parts?<span key={i}>{parts[m[1]]}</span>:s});
}

/* Small switch for the header and the login pages: EN | हिं | मर */
export function LangSwitch({className=''}:{className?:string}){
  const {lang,setLang,t}=useLang();
  return <div className={`lsw ${className}`} role="group" aria-label={t('Language')}>{LANGS.map(([c,s,n])=>
    <button key={c} type="button" lang={c} className={c===lang?'on':''} aria-pressed={c===lang} title={n} onClick={()=>setLang(c)}>{s}</button>)}</div>;
}
