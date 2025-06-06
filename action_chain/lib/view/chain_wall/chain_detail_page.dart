import 'package:action_chain/component/actodo_card.dart';
import 'package:action_chain/component/dialog/ac_yes_no_dialog.dart';
import 'package:action_chain/component/ui/action_chain_sliver_appbar.dart';
import 'package:action_chain/component/ui/controll_icon_button.dart';
import 'package:action_chain/constants/global_keys.dart';
import 'package:action_chain/model/ac_workspace/ac_workspace.dart';
import 'package:action_chain/model/external/ac_vibration.dart';
import 'package:action_chain/model/ac_todo/ac_todo.dart';
import 'package:action_chain/model/ac_todo/ac_category.dart';
import 'package:action_chain/model/ac_todo/ac_chain.dart';
import 'package:action_chain/model/ac_theme.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderables/reorderables.dart';

class ChainDetailPage extends StatefulWidget {
  final bool isSavedChain;
  final ACCategory categoryOfThisChain;
  final int indexOfThisChainInChains;
  const ChainDetailPage({
    required Key key,
    required this.isSavedChain,
    required this.categoryOfThisChain,
    required this.indexOfThisChainInChains,
  }) : super(key: key);

  @override
  State<ChainDetailPage> createState() => _ChainDetailPageState();
}

class _ChainDetailPageState extends State<ChainDetailPage> {
  ACChain get chainOfThisPage =>
      (widget.isSavedChain
              ? ACWorkspace.currentWorkspace.savedChains
              : ACWorkspace
                  .currentWorkspace.keepedChains)[widget.categoryOfThisChain.id]
          ?[widget.indexOfThisChainInChains] ??
      ACChain(title: "", actodos: []);

  bool get isComplited => (() {
        for (ACToDo method in chainOfThisPage.actodos) {
          if (!method.isChecked) {
            return false;
          }
        }
        return true;
      }());

  @override
  Widget build(BuildContext context) {
    final ACThemeData _acThemeData = ACTheme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: _acThemeData.backgroundColor),
          ),
          CustomScrollView(
            slivers: [
              ActionChainSliverAppBar(
                  pageTitle: chainOfThisPage.title,
                  titleFontSize: 15,
                  titleSpacing: 0.5,
                  leadingButtonOnPressed: () => Navigator.pop(context),
                  leadingIcon: const Icon(
                    Icons.close,
                    size: 23,
                    color: Colors.white,
                  ),
                  trailingButtonOnPressed: () async {
                    Navigator.pop(context);
                    await Future<void>.delayed(
                            const Duration(milliseconds: 100))
                        .then((_) => Navigator.pop(context));
                  },
                  trailingIcon: const Icon(
                    FontAwesomeIcons.house,
                    size: 18,
                    color: Colors.white,
                  )),
              SliverList(
                  delegate: SliverChildListDelegate([
                // Action Chainの内容を表示する
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        // 削除、編集、実行ボタン
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0, bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 削除
                              ControllIconButton(
                                  onPressed: () => ACChain.askToDeleteThisChain(
                                        context: context,
                                        categoryId:
                                            widget.categoryOfThisChain.id,
                                        indexOfOldChain:
                                            widget.indexOfThisChainInChains,
                                        isSavedChain: widget.isSavedChain,
                                      ),
                                  iconData: Icons.clear,
                                  textContent: "削除"),
                              const SizedBox(width: 20),
                              // 編集
                              ControllIconButton(
                                  onPressed: () {
                                    ACChain.askTojumpToHomePageToUseThisChain(
                                        context: context,
                                        chainName: chainOfThisPage.title,
                                        actionMethods: chainOfThisPage.actodos,
                                        indexOfChain:
                                            widget.indexOfThisChainInChains,
                                        selectedCategoryId:
                                            widget.categoryOfThisChain.id,
                                        oldCategoryId: widget.isSavedChain
                                            ? widget.categoryOfThisChain.id
                                            : null,
                                        wantToConduct: false,
                                        // keepedなら削除
                                        removeKeepedChainAction: () {
                                          if (!widget.isSavedChain) {
                                            ACWorkspace
                                                .currentWorkspace
                                                .keepedChains[widget
                                                    .categoryOfThisChain.id]!
                                                .removeAt(widget
                                                    .indexOfThisChainInChains);
                                            ACChain.saveActionChains(
                                                isSavedChains: false);
                                          }
                                        });
                                  },
                                  iconData: Icons.edit,
                                  textContent: "編集"),
                              const SizedBox(width: 20),
                              // 実行と完了
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: !isComplited
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                // 実行ボタン
                                firstChild: ControllIconButton(
                                    onPressed: () {
                                      ACChain.askTojumpToHomePageToUseThisChain(
                                          context: context,
                                          chainName: chainOfThisPage.title,
                                          actionMethods:
                                              chainOfThisPage.actodos,
                                          selectedCategoryId:
                                              widget.categoryOfThisChain.id,
                                          oldCategoryId: widget.isSavedChain
                                              ? widget.categoryOfThisChain.id
                                              : null,
                                          indexOfChain:
                                              widget.indexOfThisChainInChains,
                                          wantToConduct: true,
                                          // keepedなら削除
                                          removeKeepedChainAction: () {
                                            if (!widget.isSavedChain) {
                                              ACWorkspace
                                                  .currentWorkspace
                                                  .keepedChains[widget
                                                      .categoryOfThisChain.id]!
                                                  .removeAt(widget
                                                      .indexOfThisChainInChains);
                                              ACChain.saveActionChains(
                                                  isSavedChains: false);
                                            }
                                          });
                                    },
                                    iconData: Icons.near_me,
                                    iconSize: 26,
                                    textContent: "実行"),
                                // 完了ボタン
                                secondChild: ControllIconButton(
                                  onPressed: () => ACYesNoDialog.show(
                                      context: context,
                                      title: "このAction Chainを\n完了しますか？",
                                      message: null,
                                      yesAction: () {
                                        Navigator.pop(context);
                                        // 更新して消す
                                        ACWorkspace
                                            .currentWorkspace
                                            .keepedChains[
                                                widget.categoryOfThisChain.id]!
                                            .removeAt(widget
                                                .indexOfThisChainInChains);
                                        selectChainWallKey.currentState
                                            ?.setState(() {});
                                        homePageKey.currentState
                                            ?.setState(() {});
                                        // アラート
                                        ACVibration.vibrate();
                                        // 保存
                                        ACChain.saveActionChains(
                                            isSavedChains: false);
                                        ACWorkspace.saveCurrentWorkspace(
                                            selectedWorkspaceIndex: ACWorkspace
                                                .currentWorkspaceIndex,
                                            selectedWorkspace:
                                                ACWorkspace.currentWorkspace);
                                        ACChain.saveActionChains(
                                            isSavedChains: true);
                                      }),
                                  iconData: Icons.done,
                                  textContent: "完了",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 3.0, bottom: 5.0),
                            child: ReorderableColumn(
                              children: [
                                for (int indexOfThisActionMethod = 0;
                                    indexOfThisActionMethod <
                                        chainOfThisPage.actodos.length;
                                    indexOfThisActionMethod++)
                                  ACToDoCard(
                                      key: Key(UniqueKey().toString()),
                                      superKey: chainDetailPageKey,
                                      isCurrentChain: false,
                                      isInKeepedChain: !widget.isSavedChain,
                                      disableSliderable: true,
                                      disableTapGesture: widget.isSavedChain,
                                      actionMethods: chainOfThisPage.actodos,
                                      indexOfThisActionMethod:
                                          indexOfThisActionMethod,
                                      actionMethodData: chainOfThisPage
                                          .actodos[indexOfThisActionMethod],
                                      editAction: null)
                              ],
                              onReorder: (oldIndex, newIndex) {
                                final ACToDo reorderedActionMethod =
                                    chainOfThisPage.actodos.removeAt(oldIndex);
                                chainOfThisPage.actodos
                                    .insert(newIndex, reorderedActionMethod);
                                setState(() {});
                                ACChain.saveActionChains(
                                    isSavedChains: widget.isSavedChain);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 250),
              ]))
            ],
          ),
        ],
      ),
    );
  }
}
