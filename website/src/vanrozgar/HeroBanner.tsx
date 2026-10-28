import {ReactNode} from 'react';

/* Full-width banner: photo behind, cream text on the left over a dark gradient */
export default function HeroBanner({src,alt,eager,children}:{src:string,alt:string,eager?:boolean,children:ReactNode}){
  return <section className="hb" style={{margin:'0 calc(-1 * var(--gut))'}}>
    <img src={src} alt={alt} {...(eager?{fetchPriority:'high' as const}:{loading:'lazy' as const})} decoding="async"/>
    <div className="hb-in">{children}</div>
  </section>;
}
