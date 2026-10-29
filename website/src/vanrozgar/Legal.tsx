import {useApp} from './store';
import {LEGAL,tr} from './lang';

export default function Legal({kind}:{kind:'terms'|'privacy'}){
  const a=useApp();
  const items=LEGAL[a.lang][kind];
  return <section style={{maxWidth:760,margin:'28px auto',padding:'0 4px'}}>
    <h1 style={{color:'var(--h)',margin:'0 0 14px'}}>{tr(a.lang,kind==='terms'?'Terms of use':'Privacy policy')}</h1>
    <ul style={{lineHeight:1.7,paddingLeft:20}}>{items.map(t=><li key={t} style={{marginBottom:8}}>{t}</li>)}</ul>
    <p><a href={kind==='terms'?'#/privacy':'#/terms'} style={{color:'var(--g)'}}>{tr(a.lang,kind==='terms'?'Privacy policy':'Terms of use')}</a></p>
  </section>;
}
