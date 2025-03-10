<script>
import { GlBadge, GlLink, GlSkeletonLoading } from '@gitlab/ui';
import { visitUrl } from '~/lib/utils/url_utility';
import TimeagoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { getIconName } from '../../utils/icon';
import getRefMixin from '../../mixins/get_ref';
import getCommit from '../../queries/getCommit.query.graphql';

export default {
  components: {
    GlBadge,
    GlLink,
    GlSkeletonLoading,
    TimeagoTooltip,
  },
  apollo: {
    commit: {
      query: getCommit,
      variables() {
        return {
          fileName: this.name,
          type: this.type,
          path: this.currentPath,
          projectPath: this.projectPath,
        };
      },
    },
  },
  mixins: [getRefMixin],
  props: {
    id: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    currentPath: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: false,
      default: null,
    },
    lfsOid: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      commit: null,
    };
  },
  computed: {
    routerLinkTo() {
      return this.isFolder ? { path: `/tree/${this.ref}/${this.path}` } : null;
    },
    iconName() {
      return `fa-${getIconName(this.type, this.path)}`;
    },
    isFolder() {
      return this.type === 'tree';
    },
    isSubmodule() {
      return this.type === 'commit';
    },
    linkComponent() {
      return this.isFolder ? 'router-link' : 'a';
    },
    fullPath() {
      return this.path.replace(new RegExp(`^${this.currentPath}/`), '');
    },
    shortSha() {
      return this.id.slice(0, 8);
    },
  },
  methods: {
    openRow() {
      if (this.isFolder) {
        this.$router.push(this.routerLinkTo);
      } else {
        visitUrl(this.url);
      }
    },
  },
};
</script>

<template>
  <tr :class="`file_${id}`" class="tree-item" @click="openRow">
    <td class="tree-item-file-name">
      <i :aria-label="type" role="img" :class="iconName" class="fa fa-fw"></i>
      <component :is="linkComponent" :to="routerLinkTo" :href="url" class="str-truncated">
        {{ fullPath }}
      </component>
      <gl-badge v-if="lfsOid" variant="default" class="label-lfs ml-1">LFS</gl-badge>
      <template v-if="isSubmodule">
        @ <gl-link href="#" class="commit-sha">{{ shortSha }}</gl-link>
      </template>
    </td>
    <td class="d-none d-sm-table-cell tree-commit">
      <gl-link v-if="commit" :href="commit.commitPath" class="str-truncated-100 tree-commit-link">
        {{ commit.message }}
      </gl-link>
      <gl-skeleton-loading v-else :lines="1" class="h-auto" />
    </td>
    <td class="tree-time-ago text-right">
      <timeago-tooltip v-if="commit" :time="commit.committedDate" tooltip-placement="bottom" />
      <gl-skeleton-loading v-else :lines="1" class="ml-auto h-auto w-50" />
    </td>
  </tr>
</template>
