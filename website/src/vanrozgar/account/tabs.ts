/* The Account tabs for each role. Other roles get their own tabs later: change only this file. */
export type Tab={id:string,label:string,icon:string};

const BUYER:Tab[]=[
  {id:'overview',label:'Overview',icon:'layout-dashboard'},
  {id:'requests',label:'My requests',icon:'package'},
  {id:'wishlist',label:'Wishlist',icon:'heart'},
  {id:'cart',label:'Cart',icon:'shopping-cart'},
  {id:'profile',label:'Profile and settings',icon:'settings'},
];

export const TABS:Record<string,Tab[]>={buy:BUYER,gs:BUYER,vil:BUYER,drv:BUYER};
export const tabsFor=(role:string)=>TABS[role]||BUYER;
export const tabHref=(id:string)=>id==='overview'?'#/account':'#/account/'+id;
