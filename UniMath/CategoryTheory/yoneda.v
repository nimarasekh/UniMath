
(** **********************************************************

Benedikt Ahrens, Chris Kapulkin, Mike Shulman

january 2013


************************************************************)


(** **********************************************************

Contents : Definition of the Yoneda functor
           [yoneda(C) : [C, [C^op, HSET]]]

           Proof that [yoneda(C)] is fully faithful


TODO: this file needs cleanup

************************************************************)


Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.opp_precat.
Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.whiskering.

(*Local Notation "a --> b" := (precategory_morphisms a b)(at level 50).*)
Local Notation "'hom' C" := (precategory_morphisms (C := C)) (at level 2).
(* Local Notation "f ;; g" := (compose f g) (at level 50, format "f  ;;  g").*)
Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).
Local Notation "# F" := (functor_on_morphisms F) (at level 3).
Local Notation "C '^op'" := (opp_precat C) (at level 3, format "C ^op").

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Ltac unf := unfold identity,
                   compose,
                   precategory_morphisms;
                   simpl.

(** The following lemma is already in precategories.v . It should be transparent? *)

Lemma iso_comp_left_isweq {C:precategory} {a b:ob C} (h:iso a b) (c:C) :
  isweq (fun f : hom _ c a => f ;; h).
Proof. intros. apply (@iso_comp_right_isweq C^op b a (opp_iso h)). Qed.

(** * Yoneda functor *)

(** ** On objects *)

Definition yoneda_objects_ob (C : precategory) (c : C)
          (d : C) := hom C d c.

Definition yoneda_objects_mor (C : precategory) (c : C)
    (d d' : C) (f : hom C d  d') :
   yoneda_objects_ob C c d' -> yoneda_objects_ob C c d :=
    fun g => f ;; g.

Definition yoneda_ob_functor_data (C : precategory) (hs: has_homsets C) (c : C) :
    functor_data (C^op) HSET.
Proof.
  exists (fun c' => hSetpair (yoneda_objects_ob C c c') (hs c' c)) .
  intros a b f g. unfold yoneda_objects_ob in *. simpl in *.
  exact (f ;; g).
Defined.


Lemma is_functor_yoneda_functor_data (C : precategory) (hs: has_homsets C) (c : C) :
  is_functor (yoneda_ob_functor_data C hs c).
Proof.
  repeat split; unf; simpl.
  unfold functor_idax .
  intros.
  apply funextsec.
  intro f. unf. apply id_left.
  intros a b d f g.
  apply funextsec. intro h.
  apply (! assoc _ _ _ _ _ _ _ _ ).
Qed.

Definition yoneda_objects (C : precategory) (hs: has_homsets C) (c : C) :
             functor C^op HSET :=
    tpair _ _ (is_functor_yoneda_functor_data C hs c).


(** ** On morphisms *)

Definition yoneda_morphisms_data (C : precategory)(hs: has_homsets C) (c c' : C)
    (f : hom C c c') : forall a : ob C^op,
         hom _ (yoneda_objects C hs c a) ( yoneda_objects C hs c' a) :=
            fun a g => g ;; f.

Lemma is_nat_trans_yoneda_morphisms_data (C : precategory) (hs: has_homsets C)
     (c c' : ob C) (f : hom C c c') :
  is_nat_trans (yoneda_objects C hs c) (yoneda_objects C hs c')
    (yoneda_morphisms_data C hs c c' f).
Proof.
  unfold is_nat_trans; simpl.
  unfold yoneda_morphisms_data; simpl.
  intros d d' g.
  apply funextsec; simpl in *.
  unfold yoneda_objects_ob; simpl.
  unf; intro;
  apply  ( ! assoc _ _ _ _ _ _ _ _  ).
Qed.

Definition yoneda_morphisms (C : precategory) (hs: has_homsets C) (c c' : C)
   (f : hom C c c') : nat_trans (yoneda_objects C hs c) (yoneda_objects C hs c') :=
   tpair _ _ (is_nat_trans_yoneda_morphisms_data C hs c c' f).


Definition yoneda_functor_data (C : precategory)(hs: has_homsets C) :
   functor_data C [C^op , HSET, (pr2 is_category_HSET) ] :=
   tpair _ (yoneda_objects C hs) (yoneda_morphisms C hs).


(** ** Functorial properties of the yoneda assignments *)

Lemma is_functor_yoneda (C : precategory) (hs: has_homsets C):
  is_functor (yoneda_functor_data C hs).
Proof.
  unfold is_functor.
  repeat split; simpl.
  intro a.
  set (T:= nat_trans_eq (C:=C^op) (pr2 is_category_HSET)). simpl.
  apply T.
  intro c; apply funextsec; intro f.
  apply id_right.
  intros a b c f g.
  set (T:=nat_trans_eq (C:=C^op) (pr2 is_category_HSET)).
  apply T.
  simpl; intro d; apply funextsec; intro h.
  apply assoc.
Qed.


Definition yoneda (C : precategory) (hs: has_homsets C) :
  functor C [C^op, HSET, (pr2 is_category_HSET)] :=
   tpair _ _ (is_functor_yoneda C hs).

(* Notation "'ob' F" := (precategory_ob_mor_fun_objects F)(at level 4). *)

(** ** Yoneda lemma: natural transformations from [yoneda C c] to [F]
         are isomorphic to [F c] *)


Definition yoneda_map_1 (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET) :
       hom _ (yoneda C hs c) F -> pr1 (F c) :=
   fun h =>  pr1 h c (identity c).



Lemma yoneda_map_2_ax (C : precategory) (hs: has_homsets C) (c : C)
       (F : functor C^op HSET) (x : pr1 (F c)) :
  is_nat_trans (pr1 (yoneda C hs c)) F
         (fun (d : C) (f : hom (C ^op) c d) => #F f x).
Proof.
  intros a b f; simpl in *.
  apply funextsec.
  unfold yoneda_objects_ob; intro g.
  set (H:= functor_comp F  _ _  b g).
  unfold functor_comp in H;
  unfold opp_precat_data in H;
  simpl in *.
  apply (toforallpaths _ _ _ (H f) x).
Qed.

Definition yoneda_map_2 (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET) :
       pr1 (F c) -> hom _ (yoneda C hs c) F.
Proof.
  intro x.
  exists (fun d : ob C => fun f => #F f x).
  apply yoneda_map_2_ax.
Defined.

Lemma yoneda_map_1_2 (C : precategory) (hs: has_homsets C) (c : C)
  (F : functor C^op HSET)
  (alpha : hom _ (yoneda C hs c) F) :
      yoneda_map_2 _ _ _ _ (yoneda_map_1 _ _ _ _ alpha) = alpha.
Proof.
  simpl in *.
  set (T:=nat_trans_eq (C:=C^op) (pr2 is_category_HSET)).
  apply T.
  intro a'; simpl.
  apply funextsec; intro f.
  unfold yoneda_map_1.
  pathvia ((alpha c ;; #F f) (identity c)).
    apply idpath.
  rewrite <- nat_trans_ax.
  unf; apply maponpaths.
  apply (id_right C a' c f ).
Qed.


Lemma yoneda_map_2_1 (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET) (x : pr1 (F c)) :
   yoneda_map_1 _ _ _ _ (yoneda_map_2 _ hs  _ _ x) = x.
Proof.
  simpl.
  rewrite (functor_id F).
  apply idpath.
Qed.

Lemma isaset_nat_trans_yoneda (C: precategory) (hs: has_homsets C) (c : C)
  (F : functor C^op HSET) :
 isaset (nat_trans (yoneda_ob_functor_data C hs c) F).
Proof.
  apply isaset_nat_trans.
  apply (pr2 is_category_HSET).
Qed.



Lemma yoneda_iso_sets (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET) :
   is_isomorphism (C:=HSET)
     (a := hSetpair (hom _ ((yoneda C) hs c) F) (isaset_nat_trans_yoneda C hs c F))
     (b := F c)
     (yoneda_map_1 C hs c F).
Proof.
  set (T:=yoneda_map_2 C hs c F). simpl in T.
  set (T':= T : hom HSET (F c) (hSetpair (hom _ ((yoneda C) hs c) F)
                                         (isaset_nat_trans_yoneda C hs c F))).
  apply (is_iso_qinv (C:=HSET) _ T' ).
  repeat split; simpl.
  - apply funextsec; intro alpha.
    unf; simpl.
    apply (yoneda_map_1_2 C hs c F).
  - apply funextsec; intro x.
    unf; rewrite (functor_id F).
    apply idpath.
Defined.


Lemma isweq_yoneda_map_1 (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET) :
  isweq
     (*a := hSetpair (hom _ ((yoneda C) hs c) F) (isaset_nat_trans_yoneda C hs c F)*)
     (*b := F c*)
     (yoneda_map_1 C hs c F).
Proof.
  set (T:=yoneda_map_2 C hs c F). simpl in T.
  unshelve refine (gradth _ _ _ _ ).
  - apply T.
  - apply yoneda_map_1_2.
  - apply yoneda_map_2_1.
Defined.

Definition yoneda_weq (C : precategory) (hs: has_homsets C) (c : C)
   (F : functor C^op HSET)
  :  hom [C^op, HSET, pr2 is_category_HSET] ((yoneda C hs) c) F ≃ pr1hSet (F c)
  := weqpair _ (isweq_yoneda_map_1 C hs c F).


(** ** The Yoneda embedding is fully faithful *)

Lemma yoneda_fully_faithful (C : precategory) (hs: has_homsets C) : fully_faithful (yoneda C hs).
Proof.
  intros a b; simpl.
  apply (gradth _
      (yoneda_map_1 C hs a (pr1 (yoneda C hs) b))).
  - intro; simpl in *.
    apply id_left.
  - intro gamma.
    simpl in *.
    apply nat_trans_eq. apply (pr2 is_category_HSET).
    intro x. simpl in *.
    apply funextsec; intro f.
    unfold yoneda_map_1.
    unfold yoneda_morphisms_data.
    assert (T:= toforallpaths _ _ _ (nat_trans_ax gamma a x f) (identity _ )).
    cbn in T.
    eapply pathscomp0; [apply (!T) |].
    apply maponpaths.
    apply id_right.
Defined.


Section yoneda_functor_precomp.

Variables C D : precategory.
Variables (hsC : has_homsets C) (hsD : has_homsets D).
Variable F : functor C D.

Section fix_object.

Variable c : C.

Definition yoneda_functor_precomp' : nat_trans (yoneda_objects C hsC c)
      (functor_composite _ _ _ (functor_opp F) (yoneda_objects D hsD (F c))).
Proof.
  unshelve refine (tpair _ _ _ ).
  - intros d f ; simpl.
    apply (#F f).
  - abstract (intros d d' f ;
              apply funextsec; intro t; simpl;
              apply functor_comp).
Defined.

Definition yoneda_functor_precomp :  _ ⟦ yoneda C hsC c, functor_composite _ _ _ (functor_opp F) (yoneda_objects D hsD (F c))⟧.
Proof.
  exact yoneda_functor_precomp'.
Defined.

Variable Fff : fully_faithful F.

Lemma is_iso_yoneda_functor_precomp : is_iso yoneda_functor_precomp.
Proof.
  apply functor_iso_if_pointwise_iso.
  intro. simpl.
  set (T:= weqpair _ (Fff a c)).
  set (TA := hSetpair (hom C a c) (hsC _ _ )).
  set (TB := hSetpair (hom D (F a) (F c)) (hsD _ _ )).
  apply (hset_equiv_is_iso TA TB T).
Defined.

End fix_object.


Let A := functor_composite _ _ _ F (yoneda D hsD).
Let B := pre_composition_functor _ _ HSET (has_homsets_opp hsD) (pr2 is_category_HSET)  (functor_opp F).

Definition yoneda_functor_precomp_nat_trans :
    @nat_trans
      C
      [C^op, HSET, (pr2 is_category_HSET)]
      (yoneda C hsC)
      (functor_composite _ _ _ A B).
Proof.
  unshelve refine (tpair _ _ _ ).
  - intro c; simpl.
    apply yoneda_functor_precomp.
  - abstract (
        intros c c' f;
        apply nat_trans_eq; try apply (pr2 is_category_HSET);
        intro d; apply funextsec; intro t;
        cbn;
        apply functor_comp).
Defined.

End yoneda_functor_precomp.