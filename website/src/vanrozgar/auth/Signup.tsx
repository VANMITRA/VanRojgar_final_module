import Shell from './Shell';
import {Head} from './fields';

const ROLES=[['building-community','Gram Sabha','Manage the village stock and approve requests','gram-sabha'],['home-2','CFR villager','Sell your own forest produce','villager'],['shopping-bag','General buyer','Buy forest produce from villages','buyer']];

export default function Signup(){
  return <Shell>
    <Head title="Sign up" sub="I am a..."/>
    {ROLES.map(r=><a key={r[3]} className="role" href={`#/signup/${r[3]}`}><div className="ic"><i className={`ti ti-${r[0]}`}></i></div><div><b>{r[1]}</b><span>{r[2]}</span></div></a>)}
    <div className="center" style={{marginTop:6}}>Already have an account?<br/><a className="lk" href="#/login">Login</a></div>
  </Shell>;
}
