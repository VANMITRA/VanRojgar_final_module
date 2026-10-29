import {useEffect,useRef,useState} from 'react';
import {useApp} from './store';
import {LANGS} from './lang';

export default function LangSelect(){
  const a=useApp(),[open,setOpen]=useState(false),ref=useRef<HTMLDivElement>(null);
  useEffect(()=>{
    const out=(e:MouseEvent)=>{if(ref.current&&!ref.current.contains(e.target as Node))setOpen(false)};
    const esc=(e:KeyboardEvent)=>{if(e.key==='Escape')setOpen(false)};
    document.addEventListener('mousedown',out);document.addEventListener('keydown',esc);
    return()=>{document.removeEventListener('mousedown',out);document.removeEventListener('keydown',esc)};
  },[]);
  const cur=LANGS.find(l=>l.id===a.lang)!;
  return <div className="lang" ref={ref}>
    <button type="button" className="b2" aria-haspopup="listbox" aria-expanded={open} aria-label={a.t('Language')} onClick={()=>setOpen(!open)}><i className="ti ti-language"></i> {cur.label} <i className="ti ti-chevron-down"></i></button>
    {open&&<ul className="menu lmenu" role="listbox">{LANGS.map(l=><li key={l.id} role="option" aria-selected={l.id===a.lang} className={l.id===a.lang?'on':''} onClick={()=>{a.setLang(l.id);setOpen(false)}}>{l.label}</li>)}</ul>}
  </div>;
}
